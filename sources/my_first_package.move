module my_first_package::my_module {
    use std::hash;

    const EInvalidShoot: u64 = 0;

// public fun create_profile(ctx: &mut TxContext): Game {
//     Profile {
//         id: object::new(ctx),
//         wins1: 0,
//         wins2: 0,
//     }
// }

    public struct RPS_Game has key {
        id: UID,
        // gameboard: vector<vector<u8>>,
        // cur_turn: u8,
        // game_status: u8,
        games: u8,
        shoot1: vector<u8>,
        shoot2: u8,
        who_shot_first: u8,
        proved_first_shoot: u8,
        player1: address,
        player2: address,
        wins1: u8,
        wins2: u8,
    }

    public fun new_game(/*player1_profile: &mut Profile, player2_profile: &mut Profile,*/ player1_addy: address, player2_addy: address, ctx: &mut TxContext) {
        let game = RPS_Game {
            id: object::new(ctx),
            games: 0,
            shoot1: b"",
            shoot2: 0,
            who_shot_first: 0,
            proved_first_shoot: 0,
            // profile1: player1_profile, //my_first_package::my_module
            // profile2: player2_profile,
            wins1: 0,
            wins2: 0,
            player1: player1_addy, //ctx.sender(), 
            player2: player2_addy
        };
        transfer::share_object(game);
    }

    public fun do_1st_shoot(game: &mut RPS_Game, shoot: vector<u8>, ctx: &mut TxContext) {
        if (game.shoot1 == b"" && game.shoot2 == 0 && (game.player1 == ctx.sender() || game.player2 == ctx.sender())) {
            game.shoot1 = shoot;
        };
        if (game.player1 == ctx.sender()) {
            game.who_shot_first = 1;
        };
        if (game.player2 == ctx.sender()) {
            game.who_shot_first = 2;
        };
    }

    public fun do_2nd_shoot(game: &mut RPS_Game, shoot: u8, ctx: &mut TxContext) {
        assert!(shoot < 4 && shoot > 0 , EInvalidShoot);
        if (game.shoot1 != b"" && game.shoot2 == 0 && ((game.who_shot_first == 1 && game.player2 == ctx.sender()) || (game.who_shot_first == 2 && game.player1 == ctx.sender()))) {
            game.shoot2 = shoot;
        };
    }

    public fun prove_1st_shoot(game: &mut RPS_Game, salt: vector<u8>, shoot: u8, ctx: &mut TxContext) {
        assert!(shoot < 4 && shoot > 0 , EInvalidShoot);
        let mut combined = salt;
        combined.push_back<u8>(shoot);
        let hash = hash::sha2_256(combined);
        game.shoot1 = hash;
        // assert!(hash == game.shoot1 , EInvalidShoot);
        game.proved_first_shoot = shoot;
        game.check_for_win();
    }

    public fun hard_reset(game: &mut RPS_Game, ctx: &mut TxContext) {
        game.shoot1 = b"";
        game.shoot2 = 0;
        game.who_shot_first = 0;
        game.proved_first_shoot = 0;
    }





    fun check_for_win(game: &mut RPS_Game){
        // 1 = rock, 2 = paper, 3 = scissors
        let gs1 = game.proved_first_shoot;
        let gs2 = game.shoot2;
        if(gs1 != 0 && gs2 != 0){
            if(gs1 != gs2){
                if((gs1 == 1 && gs2 == 3) || (gs1 == 2 && gs2 == 1) || (gs1 == 3 && gs2 == 2)){
                    game.wins1 = game.wins1 + 1;
                }else{
                    game.wins2 = game.wins2 + 1;
                };
            };
            game.shoot1 = b"";
            game.shoot2 = 0;
            game.who_shot_first = 0;

        };
    }

    // Accessors
    public fun wins1(game: &RPS_Game): u8 { game.wins1 }
    public fun wins2(game: &RPS_Game): u8 { game.wins2 }

}


// sui client ptb \
//         --assign forge @<FORGE-ID> \
//         --assign to_address @<TO-ADDRESS> \
//         --move-call 0x7de3b1b9098501081ffd76c899840400aa20b454cb443db2daee6015d3705429::my_module::new_game forge 3 3 \         
//         --assign sword \                         
//         --transfer-objects "[sword]" to_address \
//         --gas-budget 20000000