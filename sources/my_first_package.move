module my_first_package::my_module {
    use std::hash;
    // use sui::object::{UID, id};

    const EInvalidShoot: u64 = 0;

    public struct GameParticipant has key, store {
        id: UID,
        game_addy: address
    }

    public struct RPS_Game has key {
        id: UID,
        game_status: u8, //current turn, TODO check for your turn
        games: u8,
        shoot1: vector<u8>,
        shoot2: u8,
        who_shot_first: u8,
        proved_first_shoot: u8,
        player1: address,
        player2: address,
        wins1: u8,
        wins2: u8,
        playTo: u8,
    }

    // public struct Profile has key, store {
    //     id: UID,
    //     points: u8,
    //     wins: u8,
    // }

    // public fun create_profile(ctx: &mut TxContext): Profile {
    //     Profile {
    //         id: object::new(ctx),
    //         points: 0,
    //         wins: 0,
    //     }
    // }

// public fun get_uid(obj: &RPS_Game): UID {
//         obj.id
//     }

    public fun new_game(/*player1_profile: &mut Profile, player2_profile: &mut Profile,*/ player1_addy: address, player2_addy: address, ctx: &mut TxContext) {
        let uid = object::new(ctx);
        let game_addy = object::uid_to_address(&uid);
        let game2 = RPS_Game {
            id: uid,
            game_status: 0,
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
            player2: player2_addy,
            playTo: 0
        };
        // let RPS_Game { id, game_status, games, shoot1, shoot2, who_shot_first, 
        // proved_first_shoot, wins1, wins2, player1, player2, playTo } = game2;
        
        // transfer::transfer(gp2, player2_addy);
        transfer::share_object(game2);
        let gp1 = create_game_participant(game_addy, ctx);
        let gp2 = create_game_participant(game_addy, ctx);
        // uuid(copy id, ctx)
        transfer::transfer(gp1, player1_addy);
        transfer::transfer(gp2, player2_addy);
    }

    public fun create_game_participant(game_addy: address, ctx: &mut TxContext) : GameParticipant{
        GameParticipant {
            id: object::new(ctx),
            game_addy: game_addy,
        }
    }

    // public fun uuid(uid: UID, ctx: &mut TxContext): GameParticipant{
    //     GameParticipant {
    //         id: object::new(ctx),
    //         game_addy: uid
    //     }
    // }


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