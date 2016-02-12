import 'dapple/test.sol';
import 'auth/authority.sol';
import 'auth/auth_test.sol';  // Vault
import 'auth/basic_authority.sol';


contract BasicAuthorityTest is Test, DSAuthorityEvents {
    DSBasicAuthority a;
    DSBasicAuthority a2;
    Vault v;
    function setUp() {
        a = new DSBasicAuthority();
        v = new Vault();
        v.updateAuthority(a, true);
    }
    function testExportAuthorized() {
        assertFalse( v.breached(), "vault started breached" );
        expectEventsExact(a);
        DSSetCanCall(this, v, bytes4(sha3("updateAuthority(address,bool)")),
                     true);

        a.setCanCall(this, v, bytes4(sha3("updateAuthority(address,bool)")),
                     true);

        v.updateAuthority( address(this), false );
        v.breach();
        assertTrue( v.breached(), "couldn't after export attempt" );
    }
    function testFailBreach() {
        assertFalse( v.breached(), "vault started breached" );
        v.breach(); // throws
    }
    function testNormalWhitelistAdd() {
        assertFalse( v.breached(), "vault started breached" );
        expectEventsExact(a);
        DSSetCanCall(this, v, bytes4(sha3("breach()")), true);

        a.setCanCall( me, address(v), bytes4(sha3("breach()")), true );
        v.breach();
        assertTrue( v.breached() );
        v.reset();
        assertFalse( v.breached(), "vault not reset" );
    }
    function testFailNormalWhitelistReset() {
        assertFalse( v.breached(), "vault started breached" );
        expectEventsExact(a);
        DSSetCanCall(this, v, bytes4(sha3("breach()")), false);

        a.setCanCall( me, address(v), bytes4(sha3("breach()")), true );
        v.breach();
        assertTrue( v.breached() );
        a.setCanCall( me, address(v), bytes4(sha3("breach()")), false );
        v.breach();
    }
}
