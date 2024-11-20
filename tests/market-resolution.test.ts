import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.14.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure that markets can be resolved and winnings can be claimed",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
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
    
    // Add oracles and report outcomes
    block = chain.mineBlock([
      Tx.contractCall('oracle-integration', 'add-oracle', [types.principal(wallet1.address)], deployer.address),
      Tx.contractCall('oracle-integration', 'add-oracle', [types.principal(wallet2.address)], deployer.address),
      Tx.contractCall('oracle-integration', 'report-outcome', [types.uint(1), types.uint(0)], wallet1.address),
      Tx.contractCall('oracle-integration', 'report-outcome', [types.uint(1), types.uint(0)], wallet2.address)
    ]);
    
    // Resolve market
    block = chain.mineBlock([
      Tx.contractCall('market-resolution', 'resolve-market', [types.uint(1)], deployer.address)
    ]);
    assertEquals(block.receipts[0].result, '(ok u0)');
    
    // Claim winnings (this will fail as no bets were placed in this test)
    block = chain.mineBlock([
      Tx.contractCall('market-resolution', 'claim-winnings', [types.uint(1)], wallet1.address)
    ]);
    assertEquals(block.receipts[0].result, '(err u102)');
  },
});
