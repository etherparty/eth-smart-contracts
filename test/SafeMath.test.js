const { assertRevert } = require('./helpers/assertRevert');

var SafeMathMock = artifacts.require('mocks/SafeMathMock.sol');

contract('SafeMath', function (accounts) {
    let safeMath;

    before(async function () {
        safeMath = await SafeMathMock.new();
    });

    it('multiplies correctly', async function () {
        let a = 5678;
        let b = 1234;

        let result = await safeMath.mul(a, b);
        assert.equal(result, a * b);
    });

    it('divides correctly', async function () {
        let a = 5678;
        let b = 1234;

        let result = await safeMath.div(a, b);

        assert.equal(result, 4);
    });

    it('adds correctly', async function () {
        let a = 5678;
        let b = 1234;

        let result = await safeMath.add(a, b);

        assert.equal(result, a + b);
    });

    it('subtracts correctly', async function () {
        let a = 5678;
        let b = 1234;

        let result = await safeMath.sub(a, b);

        assert.equal(result, a - b);
    });

    it('should throw an error if subtraction result would be negative', async function () {
        let a = 1234;
        let b = 5678;
        try {
            await safeMath.sub(a, b);
            assert.fail('should have thrown before');
        } catch (error) {

        }
    });

    it('should throw an error if dividing by 0', async function () {
        let a = 1234;
        let b = 0;
        try {
            await safeMath.div(a, b);
            assert.fail('should have thrown before');
        } catch (error) {

        }
    });

    it('should throw an error on addition overflow', async function () {
        let a = "115792089237316195423570985008687907853269984665640564039457584007913129639935";
        let b = 1;

        try {
            await safeMath.add(a, b);
            assert.fail('should have thrown before');
        } catch (error) {

        }

    });

    it('should throw an error on multiplication overflow', async function () {
        let a = "115792089237316195423570985008687907853269984665640564039457584007913129639933";
        let b = 2;

        await assertRevert(safeMath.mul(a, b));
    });

});
