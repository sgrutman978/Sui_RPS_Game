module my_first_package::my_module {
 use sui::test_scenario::{Self, Scenario};
    // const MARK_EMPTY: u8 = 0;
    // const MARK_X: u8 = 1;
    // const MARK_O: u8 = 2;

    const EInvalidShoot: u64 = 0;
    // const EAlreadyShot: u64 = 1;

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
    // use sui::test_scenario;

    // Create test addresses representing users
    let p1 = @0xCAFE;
    let p2 = @0xFACE;

    // let mut game_val = scenario.take_shared<RPS_Game>();
    // let game = &mut game_val;

    // let game = new_game(p2, scenario.ctx());

    // First transaction executed by initial owner to create the sword
    // let mut scenario = test_scenario::begin(p1);
  
     let mut scenario_val = test_scenario::begin(p1);
        let scenario = &mut scenario_val;
        my_first_package::my_module::new_game(copy p1, copy p2, scenario.ctx());
        // Player1 places an X in (1, 1).
        // test_make_move(2, p1, scenario);
  
    // Second transaction executed by the initial sword owner
    test_make_move(2, 0, 0, 0, p1, scenario);
    // scenario.next_tx(p1);
    // {
    //     // test_make_move(2, p2, scenario);
    //     let mut game_val = scenario.take_shared<RPS_Game>();
    //     let game = &mut game_val;
    //     game.make_move(2, scenario.ctx());
    //     assert!(game.wins1() == 0 && game.wins2() == 0, 1);
    //     test_scenario::return_shared(game_val);
    // };

    // let mut game_val = scenario.take_shared<RPS_Game>();
    //         let game = &mut game_val;
    //         game.make_move(shoot, scenario.ctx());
    //         test_scenario::return_shared(game_val);
test_make_move(1, 3, 1, 0, p2, scenario);
    //   scenario.next_tx(p2);
    // {
    //     let mut game_val = scenario.take_shared<RPS_Game>();
    //     let game = &mut game_val;
    //     game.make_move(1, scenario.ctx());
    //     assert!(game.wins1() == 1 && game.wins2() == 0, 1);
    //     game.make_move(3, scenario.ctx());
    //     test_scenario::return_shared(game_val);
    // };
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
    //   scenario.next_tx(p2);
    // {
    //     let mut game_val = scenario.take_shared<RPS_Game>();
    //     let game = &mut game_val;
    //     game.make_move(2, scenario.ctx());
    //     assert!(game.wins1() == 2 && game.wins2() == 1, 1);
    //     game.make_move(1, scenario.ctx());
    //     test_scenario::return_shared(game_val);
    // };
test_make_move(3, 0, 2, 2, p1, scenario);
    //   scenario.next_tx(p1);
    // {
    //     let mut game_val = scenario.take_shared<RPS_Game>();
    //     let game = &mut game_val;
    //     game.make_move(3, scenario.ctx());
    //     assert!(game.wins1() == 2 && game.wins2() == 2, 1);
    //     test_scenario::return_shared(game_val);
    // };

    // Third transaction executed by the final sword owner
    // scenario.next_tx(p2);
    // {
    //     // Extract the sword owned by the final owner
    //     let sword = scenario.take_from_sender<Sword>();
    //     // Verify that the sword has expected properties
    //     assert!(sword.magic() == 42 && sword.strength() == 7, 1);
    //     // Return the sword to the object pool (it cannot be simply "dropped")
    //     scenario.return_to_sender(sword)
    // };
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

//     #[test]
//     fun test_module_init() {
//         use sui::test_scenario;

//         // Create test addresses representing users
//         let p1 = @0xCAFE;
//         let p2 = @0xFACE;

//          let mut ctx = tx_context::dummy();

// //     // Create a sword
// //     let sword = Sword {
// //         id: object::new(&mut ctx),

//         // First transaction to emulate module initialization
//         let mut scenario = test_scenario::begin(admin);
//         {

//             // init(scenario.ctx());
//         };

//         // Second transaction to check if the forge has been created
//         // and has initial value of zero swords created
//         // scenario.next_tx(admin);
//         // {
//         //     // Extract the Forge object
//         //     let forge = scenario.take_from_sender<Forge>();
//         //     // Verify number of created swords
//         //     assert!(forge.swords_created() == 0, 1);
//         //     // Return the Forge object to the object pool
//         //     scenario.return_to_sender(forge);
//         // };

//         // Third transaction executed by admin to create the sword
//         scenario.next_tx(player1);
//         {
//             let mut forge = scenario.take_from_sender<Forge>();
//             // Create the sword and transfer it to the initial owner
//             let sword = forge.new_game(scenario.ctx());
//             transfer::public_transfer(sword, initial_owner);
//             scenario.return_to_sender(forge);
//         };
//         scenario.end();
//     }

}





    // Part 1: These imports are provided by default
    // use sui::object::{Self, UID};
    // use sui::transfer;
    // use sui::tx_context::{Self, TxContext};

    // Part 2: struct definitions
    // public struct Win_Tile has key, store {
    //     id: UID,
    //     type: u64, 
    //     color: u64,
    // }

    // public struct Card has key, store {
    //     id: UID,
    //     type: u64, 
    //     color: u64,
    //     numb: u64,
    // }

    // public struct Game has key, store {
    //     id: UID,
    //     player1WinTiles: vector<Win_Tile>,
    //     player2WinTiles: vector<Win_Tile>,
    //     currentPlayer1: Card,
    //     currentPlayer2: Card,
    // }

    // public struct AdminObj has key {
    //     id: UID,
    //     games_created: u64,
    // }

        // Part 3: Module initializer to be executed when this module is published
    // fun init(ctx: &mut TxContext) {
    //     let admin = AdminObj {
    //         id: object::new(ctx),
    //         games_created: 0,
    //     };
    //     // Transfer the forge object to the module/package publisher
    //     transfer::transfer(admin, ctx.sender());
    // }

    // Part 4: Accessors required to read the struct fields
    // public fun card_type(self: &Card): u64 { self.type }
    // public fun card_color(self: &Card): u64 { self.color }
    // public fun card_numb(self: &Card): u64 { self.type }
    // public fun win_tile_type(self: &Card): u64 { self.type }
    // public fun win_tile_color(self: &Card): u64 { self.color }

    // public fun games_created(self: &Forge): u64 { self.games_created }

    // public fun game_player1_win_tiles(self: &Game): u64 { self.player1WinTiles }
    // public fun game_player2_win_tiles(self: &Game): u64 { self.player2WinTiles }
    // public fun current_player1(self: &Game): u64 { self.current_player1 }
    // public fun current_player2(self: &Game): u64 { self.current_player1 }


    // Part 5: Public/entry functions (introduced later in the tutorial)

//     public fun sword_create(magic: u64, strength: u64, ctx: &mut TxContext): Sword {
//     // Create a sword
//     Sword {
//         id: object::new(ctx),
//         magic: magic,
//         strength: strength,
//     }
// }

// public fun create_profile(ctx: &mut TxContext): Game {
//     Profile {
//         id: object::new(ctx),
//         wins1: 0,
//         wins2: 0,
//     }
// }

   // Part 6: Tests

//     #[test]
// fun test_sword_create() {
//     // Create a dummy TxContext for testing
//     let mut ctx = tx_context::dummy();

//     // Create a sword
//     let sword = Sword {
//         id: object::new(&mut ctx),
//         magic: 42,
//         strength: 7,
//     };

//     // Check if accessor functions return correct values
//     assert!(sword.magic() == 42 && sword.strength() == 7, 1);
    
//     // Create a dummy address and transfer the sword
//     let dummy_address = @0xCAFE;
//     transfer::public_transfer(sword, dummy_address);
// }

// #[test]
// fun test_sword_transactions() {
//     use sui::test_scenario;

//     // Create test addresses representing users
//     let player1 = @0xCAFE;
//     let player2 = @0xFACE;

//     // First transaction executed by initial owner to create the sword
//     let mut scenario = test_scenario::begin(player1);
//     {
//         // Create the sword and transfer it to the initial owner
//         let game = game_create(42, 7, scenario.ctx());
//         transfer::public_transfer(sword, initial_owner);
//     };

//     // Second transaction executed by the initial sword owner
//     scenario.next_tx(initial_owner);
//     {
//         // Extract the sword owned by the initial owner
//         let sword = scenario.take_from_sender<Sword>();
//         // Transfer the sword to the final owner
//         transfer::public_transfer(sword, final_owner);
//     };

//     // Third transaction executed by the final sword owner
//     scenario.next_tx(final_owner);
//     {
//         // Extract the sword owned by the final owner
//         let sword = scenario.take_from_sender<Sword>();
//         // Verify that the sword has expected properties
//         assert!(sword.magic() == 42 && sword.strength() == 7, 1);
//         // Return the sword to the object pool (it cannot be simply "dropped")
//         scenario.return_to_sender(sword)
//     };
//     scenario.end();
// }