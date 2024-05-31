module my_first_package::my_module {
    use sui::test_scenario::{Self, Scenario};
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
        shoot1: u8,
        shoot2: u8,
        player1: address,
        player2: address,
        wins1: u8,
        wins2: u8,
    }

    public fun new_game(/*player1_profile: &mut Profile, player2_profile: &mut Profile,*/ player1_addy: address, player2_addy: address, ctx: &mut TxContext) {
        let game = RPS_Game {
            id: object::new(ctx),
            games: 0,
            shoot1: 0,
            shoot2: 0,
            // profile1: player1_profile, //my_first_package::my_module
            // profile2: player2_profile,
            wins1: 0,
            wins2: 0,
            player1: player1_addy, //ctx.sender(), 
            player2: player2_addy
        };
        transfer::share_object(game);
    }

    public fun make_move(game: &mut RPS_Game, shoot: u8, ctx: &mut TxContext) {
        assert!(shoot < 4 && shoot > 0 , EInvalidShoot);
        if (game.shoot1 == 0 && game.player1 == ctx.sender()) {
            game.shoot1 = shoot;
        };
        if (game.shoot2 == 0 && game.player2 == ctx.sender()) {
            game.shoot2 = shoot;
        };
        game.check_for_win();
    }

    fun check_for_win(game: &mut RPS_Game){
        // 1 = rock, 2 = paper, 3 = scissors
        let gs1 = game.shoot1;
        let gs2 = game.shoot2;
        if(gs1 != 0 && gs2 != 0){
            if(gs1 != gs2){
                if((gs1 == 1 && gs2 == 3) || (gs1 == 2 && gs2 == 1) || (gs1 == 3 && gs2 == 2)){
                    game.wins1 = game.wins1 + 1;
                }else{
                    game.wins2 = game.wins2 + 1;
                };
            };
            game.shoot1 = 0;
            game.shoot2 = 0;
        };
    }

    // Accessors
    public fun wins1(game: &RPS_Game): u8 { game.wins1 }
    public fun wins2(game: &RPS_Game): u8 { game.wins2 }

    // Tests

    #[test]
fun test_game() {
    // Create test addresses representing users
    let p1 = @0xCAFE;
    let p2 = @0xFACE;

    let mut scenario_val = test_scenario::begin(p1);
    let scenario = &mut scenario_val;
    my_first_package::my_module::new_game(copy p1, copy p2, scenario.ctx());

    test_make_move(2, 0, 0, 0, p1, scenario);
    test_make_move(1, 3, 1, 0, p2, scenario);
    test_make_move(2, 3, 1, 1, p1, scenario);
    scenario.next_tx(p1);
    {
        let mut game_val = scenario.take_shared<RPS_Game>();
        let game = &mut game_val;
        // This will NOT reset the shoot because thats not allowed
        game.make_move(2, scenario.ctx());
        test_scenario::return_shared(game_val);
    };
    test_make_move(2, 1, 2, 1, p2, scenario);
    test_make_move(3, 0, 2, 2, p1, scenario);

    scenario_val.end();
}


    fun test_make_move(
        shoot: u8,
        shoot2: u8,
        wins1: u8,
        wins2: u8,
        player: address,
        scenario: &mut Scenario,
    ) {
        // The gameboard is now a shared object.
        // Any player can place a mark on it directly.
        scenario.next_tx(player);
        {
            let mut game_val = scenario.take_shared<RPS_Game>();
            let game = &mut game_val;
            if(shoot != 0){
                game.make_move(shoot, scenario.ctx());
            };
            assert!(game.wins1() == wins1 && game.wins2() == wins2, 1);
            if(shoot2 != 0){
                game.make_move(shoot2, scenario.ctx());
            };
            test_scenario::return_shared(game_val);
        };
    }

}

