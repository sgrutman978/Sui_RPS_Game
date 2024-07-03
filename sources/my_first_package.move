module my_first_package::my_module {
    use std::hash;

    const EInvalidShoot: u64 = 0;

    public struct GameParticipant has key, store {
        id: UID,
        game_addy: address
    }

    public struct RPS_Game has key {
        id: UID,
        status: u8, //current turn, TODO check for your turn
        games: u8,
        shoot1: vector<u8>,
        shoot2: u8,
        who_shoots_first: u8,
        proved_first_shoot: u8,
        player1: address,
        player2: address,
        wins1: u8,
        wins2: u8,
        playTo: u8,
    }

    public fun new_game(/*player1_profile: &mut Profile, player2_profile: &mut Profile,*/ player1_addy: address, player2_addy: address, ctx: &mut TxContext) {
        let uid = object::new(ctx);
        let game_addy = object::uid_to_address(&uid);
        let game2 = RPS_Game {
            id: uid,
            status: 0,
            games: 0,
            shoot1: b"",
            shoot2: 0,
            who_shoots_first: 1,
            proved_first_shoot: 0,
            wins1: 0,
            wins2: 0,
            player1: player1_addy, //ctx.sender(), 
            player2: player2_addy,
            playTo: 0
        };
        transfer::share_object(game2);
        let gp1 = create_game_participant(game_addy, ctx);
        let gp2 = create_game_participant(game_addy, ctx);
        transfer::transfer(gp1, player1_addy);
        transfer::transfer(gp2, player2_addy);
    }

    public fun create_game_participant(game_addy: address, ctx: &mut TxContext) : GameParticipant{
        GameParticipant {
            id: object::new(ctx),
            game_addy: game_addy,
        }
    }

    public fun do_1st_shoot(game: &mut RPS_Game, shoot: vector<u8>, ctx: &mut TxContext) {
        assert!(game.status == 0 , EInvalidShoot);
        if ((game.player1 == ctx.sender() && game.who_shoots_first == 1) || (game.player2 == ctx.sender() && game.who_shoots_first == 2)) {
            game.shoot1 = shoot;
            game.status = 1;
        };
    }

    public fun do_2nd_shoot(game: &mut RPS_Game, shoot: u8, ctx: &mut TxContext) {
        assert!(shoot < 4 && shoot > 0 && game.status == 1 , EInvalidShoot);
        if ((game.who_shoots_first == 1 && game.player2 == ctx.sender()) || (game.who_shoots_first == 2 && game.player1 == ctx.sender())) {
            game.shoot2 = shoot;
            game.status = 2;
        };
    }

    public fun prove_1st_shoot(shoot: u8, game: &mut RPS_Game, salt: vector<u8>, ctx: &mut TxContext) {
        assert!(shoot < 4 && shoot > 0 && game.status == 2 , EInvalidShoot);
        let mut combined = salt;
        combined.push_back<u8>(shoot);
        let hash = hash::sha2_256(combined);
        // assert!(hash == game.shoot1 , EInvalidShoot);
        game.proved_first_shoot = shoot;
        game.check_for_win();
    }

    public fun hard_reset(game: &mut RPS_Game, ctx: &mut TxContext) {
        game.shoot1 = b"";
        game.shoot2 = 0;
        game.who_shoots_first = 1;
        game.proved_first_shoot = 0;
        game.status = 0;
    }

    fun check_for_win(game: &mut RPS_Game){
        // 1 = rock, 2 = paper, 3 = scissors
        let gs1 = game.proved_first_shoot;
        let gs2 = game.shoot2;
        if (gs1 != 0 && gs2 != 0){
            if (gs1 != gs2){
                if ((gs1 == 1 && gs2 == 3) || (gs1 == 2 && gs2 == 1) || (gs1 == 3 && gs2 == 2)){
                    game.wins1 = game.wins1 + 1;
                } else {
                    game.wins2 = game.wins2 + 1;
                };
            };
            game.shoot1 = b"";
            game.shoot2 = 0;
            game.status = 0;
            if (game.who_shoots_first == 1){
                game.who_shoots_first = 2;
            } else {
                game.who_shoots_first = 1;
            }

        };
    }

    // Accessors
    public fun wins1(game: &RPS_Game): u8 { game.wins1 }
    public fun wins2(game: &RPS_Game): u8 { game.wins2 }

}
