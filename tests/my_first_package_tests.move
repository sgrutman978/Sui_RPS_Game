
// #[test_only]
// module my_first_package::my_first_package_tests {
//     use my_first_package::my_module::Sword;
//     // uncomment this line to import the module
//     // use my_first_package::my_first_package;

//     const ENotImplemented: u64 = 0;

//     #[test]
//     fun test_my_first_package() {
//         // pass
//     }



//     #[test, expected_failure(abort_code = ::my_first_package::my_first_package_tests::ENotImplemented)]
//     fun test_my_first_package_fail() {
//         abort ENotImplemented
//     }
// }

#[test_only]
module my_first_package::my_module_tests {
    use sui::test_scenario::{Self, Scenario};
    use my_first_package::my_module::{RPS_Game};
    use std::hash;

   #[test]
fun test_game() {
    // Create test addresses representing users
    let p1 = @0xCAFE;
    let p2 = @0xFACE;

    let mut scenario_val = test_scenario::begin(p1);
    let scenario = &mut scenario_val;
    my_first_package::my_module::new_game(copy p1, copy p2, scenario.ctx());

    test_make_1st_move(2, b"hello", p1, scenario);
    test_make_2nd_move(1, p2, scenario);
    test_prove_1st_move(2, b"hello", 1, 0, p1, scenario);
    // scenario.next_tx(p1);
    // {
    //     let mut game_val = scenario.take_shared<RPS_Game>();
    //     let game = &mut game_val;
    //     // This will NOT reset the shoot because thats not allowed
    //     game.make_move(2, scenario.ctx());
    //     test_scenario::return_shared(game_val);
    // };
    // test_make_move(2, 1, 2, 1, p2, scenario);
    // test_make_move(3, 0, 2, 2, p1, scenario);

    scenario_val.end();
}


    fun test_make_1st_move(
        shoot: u8,
        salt: vector<u8>,
        player: address,
        scenario: &mut Scenario,
    ) {
        // The gameboard is now a shared object.
        // Any player can place a mark on it directly.
        scenario.next_tx(player);
        {
            let mut game_val = scenario.take_shared<RPS_Game>();
            let game = &mut game_val;
            let mut combined = salt;
            combined.push_back<u8>(shoot);
            let hash = hash::sha2_256(combined);
            game.do_1st_shoot(hash, scenario.ctx());
            test_scenario::return_shared(game_val);
        };
    }

    fun test_make_2nd_move(
        shoot: u8,
        player: address,
        scenario: &mut Scenario,
    ) {
        // The gameboard is now a shared object.
        // Any player can place a mark on it directly.
        scenario.next_tx(player);
        {
            let mut game_val = scenario.take_shared<RPS_Game>();
            let game = &mut game_val;
            game.do_2nd_shoot(shoot, scenario.ctx());
            test_scenario::return_shared(game_val);
        };
    }

    fun test_prove_1st_move(
        shoot: u8,
        salt: vector<u8>,
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
            game.prove_1st_shoot(salt, shoot, scenario.ctx());
            assert!(game.wins1() == wins1 && game.wins2() == wins2, 1);
            test_scenario::return_shared(game_val);
        };
    }

}