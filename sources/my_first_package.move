module my_first_package::RPSLS {
    use std::hash;
    // use std::string::String;


    // use std::signer;
    // use std::address;
    // use std::tx_context;
    // use std::vector;
    use sui::vec_map;

        /// A struct representing a user profile
    public struct Profile has key {
        id: UID,
        owner: address,
        created_at: u64,
        shared_object_ids: vector<u64>,
    }

    /// A table to store profiles by their owner's address
    public struct ProfileTable has store {
        id: UID,
        profiles: sui::vec_map<address, Profile>,
    }

      /// Initializes the ProfileTable and stores it in the signer's account
    public fun init(ctx: &mut tx_context::TxContext) {
        let profile_table = ProfileTable {
            id: object::new(ctx),
            profiles: sui::vec_map::empty(),
        };
        transfer::public_transfer(profile_table, ctx.sender());
    }


    const EInvalidShoot: u64 = 0;

    // public struct Profile {
    //         id: UID,
    //         myTurnCount: u8, //cant make new move or game or whatever if needing to provide proof on a game
    //         // username: vector<u8>,
    //         games: vector<UID>
    //     };

    public struct RPSLS_Game has key {
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
        playTo: u8,
    }

    // fun create_profile(firstGame: UID, ctx: &mut TxContext): Game {
    //     let prof = Profile {
    //         id: object::new(ctx),
    //         status: 1, 
    //         // username: vector<u8>,
    //         games: vector[firstGame]
    //     };
    //     sui::transfer::public_transfer(prof, ctx.sender());
    // }

    public fun new_game(/*player1_profile: &mut Profile, player2_profile: &mut Profile,*/ player1_addy: address, player2_addy: address, playToParam: u8, ctx: &mut TxContext) {
        let newObjId = object::new(ctx);
        // create_profile(ctx);//newObjId);
        // TODO if no profile for your address, create it here and add the game created below to it
        let game = RPSLS_Game {
            id: newObjId,
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
            playTo: playToParam
        };
        // TODO send invite object to other player? to let them know theres a game waiting for them,
            //and to allow them to create a profile / add game to profile
        transfer::share_object(game);
    }

    public fun do_1st_shoot(game: &mut RPSLS_Game, shoot: vector<u8>, ctx: &mut TxContext) {
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

    public fun do_2nd_shoot(game: &mut RPSLS_Game, shoot: u8, ctx: &mut TxContext) {
        assert!(shoot < 4 && shoot > 0 , EInvalidShoot);
        if (game.shoot1 != b"" && game.shoot2 == 0 && ((game.who_shot_first == 1 && game.player2 == ctx.sender()) || (game.who_shot_first == 2 && game.player1 == ctx.sender()))) {
            game.shoot2 = shoot;
        };
    }

    public fun prove_1st_shoot(game: &mut RPSLS_Game, salt: vector<u8>, shoot: u8) {
        assert!(shoot < 4 && shoot > 0 , EInvalidShoot);
        let mut combined = salt;
        combined.push_back<u8>(shoot);
        let hash = hash::sha2_256(combined);
        game.shoot1 = hash;
        // assert!(hash == game.shoot1 , EInvalidShoot);
        game.proved_first_shoot = shoot;
        game.check_for_win();
    }

    public fun hard_reset(game: &mut RPSLS_Game) {
        game.shoot1 = b"";
        game.shoot2 = 0;
        game.who_shot_first = 0;
        game.proved_first_shoot = 0;
    }

    fun check_for_win(game: &mut RPSLS_Game){
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
    public fun wins1(game: &RPSLS_Game): u8 { game.wins1 }
    public fun wins2(game: &RPSLS_Game): u8 { game.wins2 }










  

    /// Creates a profile for a given address if it doesn't exist already
    public entry fun create_profile(
        ctx: &mut tx_context::TxContext
    ) {
        let profile_table = &mut borrow_global_mut<ProfileTable>(tx_context::sender(ctx)).profiles;

        if (!map::contains_key(profile_table, ctx.sender())) {
            let new_profile = Profile {
                owner: addr,
                created_at: tx_context::get_tx_timestamp(ctx),
                shared_object_ids: vector::empty(),
            };
            map::insert(profile_table, addr, new_profile);
        } else {
            // Profile already exists, do nothing or handle accordingly
        }
    }

    /// Adds a shared object ID to a profile
    public entry fun add_shared_object(
        ctx: &mut tx_context::TxContext,
        addr: address,
        object_id: u64,
    ) {
        let profile_table = &mut borrow_global_mut<ProfileTable>(tx_context::sender(ctx)).profiles;

        assert!(map::contains_key(profile_table, addr), 0);
        let profile = &mut sui::vec_map::try_get(profile_table, addr);
        vector::push_back(&mut profile.shared_object_ids, object_id);
    }

    /// Get a profile by address
    public fun get_profile(
        addr: address
    ): &Profile acquires ProfileTable {
        let profile_table = borrow_global<ProfileTable>(address::default()).profiles;
        assert!(sui::vec_map::contains_key(profile_table, addr), 0);
        &map::borrow(profile_table, addr)
    }
}













// sui client ptb \
//         --assign forge @<FORGE-ID> \
//         --assign to_address @<TO-ADDRESS> \
//         --move-call 0x7de3b1b9098501081ffd76c899840400aa20b454cb443db2daee6015d3705429::my_module::new_game forge 3 3 \         
//         --assign sword \                         
//         --transfer-objects "[sword]" to_address \
//         --gas-budget 20000000