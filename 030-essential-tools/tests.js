QUnit.test("QUnit rockzzz", function(assert) {
  assert.ok(1 === 1, '1 should be qual to 1');
  assert.notOk(false, 'false if falsey');
  assert.equal(1 + 1, 2);
  assert.deepEqual([1, 2, 3], [1, 2, 3], 'deepEqual is so cool');

  throw new Error('crash the tests');
});

