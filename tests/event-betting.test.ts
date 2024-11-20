;; tests/event-betting_test.ts

import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.14.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure that markets can be created and bets can be placed",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    const wallet2 = accounts.get('wallet_2')!;
    
    // Create a market
    let block = chain.mineBlock([
      Tx.contractCall('event-betting', 'create-market', [
        types.ascii("Who will win the World Cup?"),
        types.list([types.ascii("Team A"), types.ascii("Team B"), types.ascii("Team C")]),
        types.uint(100)
      ], wallet1.address)
    ]);
    assertEquals(block.receipts[0].result, '(ok u1)');
    
    // Place a bet
    block = chain.mineBlock([
      Tx.contractCall('event-betting', 'place-bet', [
        types.uint(1),
        types.uint(0),
        types.uint(1000000)
      ], wallet2.address)
    ]);
    assertEquals(block.receipts[0].result, '(ok (u1000000 u0 u0 u0 u0))');
    
    // Get market details
    let result = chain.callReadOnlyFn('event-betting', 'get-market', [types.uint(1)], wallet1.address);
    assertEquals(result.result.expectSome().expectTuple()['resolved'], types.bool(false));
    
    // Get bets
    result = chain.callReadOnlyFn('event-betting', 'get-bets', [types.uint(1), types.principal(wallet2.address)], wallet1.address);
    assertEquals(result.result.expectSome(), '(u1000000 u0 u0 u0 u0)');
  },
});
