import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.14.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure that oracles can be added and report outcomes",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    // Add an oracle
    let block = chain.mineBlock([
      Tx.contractCall('oracle-integration', 'add-oracle', [types.principal(wallet1.address)], deployer.address)
    ]);
    assertEquals(block.receipts[0].result, '(ok true)');
    
    // Report outcome
    block = chain.mineBlock([
      Tx.contractCall('oracle-integration', 'report-outcome', [types.uint(1), types.uint(0)], wallet1.address)
    ]);
    assertEquals(block.receipts[0].result, '(ok true)');
    
    // Get oracle report
    let result = chain.callReadOnlyFn('oracle-integration', 'get-oracle-report', [types.uint(1), types.principal(wallet1.address)], deployer.address);
    assertEquals(result.result.expectSome(), types.uint(0));
  },
});
