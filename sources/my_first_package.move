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
        // dummy: vector<u8>,
        shoot2: u8,
        who_shoots_first: u8,
        proved_first_shoot: u8,
        player1: address,
        player2: address,
        wins1: u8,
        wins2: u8,
        playTo: u8,
        ties: u8,
        // hash: vector<u8>,
    }

    public fun new_game(/*player1_profile: &mut Profile, player2_profile: &mut Profile,*/ player1_addy: address, player2_addy: address, ctx: &mut TxContext) {
        let uid = object::new(ctx);
        let game_addy = object::uid_to_address(&uid);
        let game2 = RPS_Game {
            id: uid,
            status: 0,
            games: 0,
            shoot1: b"",
            // dummy: b"",
            shoot2: 0,
            who_shoots_first: 1,
            proved_first_shoot: 0,
            wins1: 0,
            wins2: 0,
            player1: player1_addy, //ctx.sender(), 
            player2: player2_addy,
            playTo: 0,
            ties: 0,
            // hash: b""
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
        combined.push_back<u8>((shoot+48));
        // game.hash = combined;
        // let hash = hash::sha2_256(combined);
        let hash = sha256_to_hex(combined);
        // game.dummy = hash;
        assert!(hash == game.shoot1 , EInvalidShoot);
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
                if((game.who_shoots_first == 1 && ((gs1 == 1 && gs2 == 3) || (gs1 == 2 && gs2 == 1) || (gs1 == 3 && gs2 == 2))) ||
                    (game.who_shoots_first == 2 && ((gs1 == 3 && gs2 == 1) || (gs1 == 1 && gs2 == 2) || (gs1 == 2 && gs2 == 3)))){
                    game.wins1 = game.wins1 + 1;
                } else {
                    game.wins2 = game.wins2 + 1;
                }
                // if(game.who_shoots_first == 1){
                //     if ((gs1 == 1 && gs2 == 3) || (gs1 == 2 && gs2 == 1) || (gs1 == 3 && gs2 == 2)){
                //         game.wins1 = game.wins1 + 1;
                //     } else {
                //         game.wins2 = game.wins2 + 1;
                //     };
                // } else {
                //     if ((gs1 == 1 && gs2 == 3) || (gs1 == 2 && gs2 == 1) || (gs1 == 3 && gs2 == 2)){
                //         game.wins2 = game.wins2 + 1;
                //     } else {
                //         game.wins1 = game.wins1 + 1;
                //     };
                // }
            }else{
                game.ties = game.ties + 1;
            };
            game.shoot1 = b"";
            game.shoot2 = 0;
            game.status = 0;
            if (game.who_shoots_first == 1){
                game.who_shoots_first = 2;
            } else {
                game.who_shoots_first = 1;
            };
            game.games = game.games + 1;
        };
    }

    // Accessors
    public fun wins1(game: &RPS_Game): u8 { game.wins1 }
    public fun wins2(game: &RPS_Game): u8 { game.wins2 }


    public fun byte_to_hex(byte: u8): vector<u8> {
        let hex_chars = b"0123456789abcdef";
        let high_nibble = (byte >> 4) & 0x0F;
        let low_nibble = byte & 0x0F;
        let high_char = *vector::borrow(&hex_chars, high_nibble as u64);
        let low_char = *vector::borrow(&hex_chars, low_nibble as u64);
        let mut result = vector::empty<u8>();
        vector::push_back(&mut result, high_char);
        vector::push_back(&mut result, low_char);
        result
    }

    public fun bytes_to_hex(bytes: vector<u8>): vector<u8> {
        let mut hex_string = vector::empty<u8>();
        let len = vector::length(&bytes);
        let mut i = 0;
        while (i < len) {
            let byte = *vector::borrow(&bytes, i);
            let hex_byte = byte_to_hex(byte);
            vector::append(&mut hex_string, hex_byte);
            i = i + 1;
        };
        hex_string
    }

    public fun sha256_to_hex(input: vector<u8>): vector<u8> {
        let hash = std::hash::sha2_256(input);
        bytes_to_hex(hash)
    }


}
