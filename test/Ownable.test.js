const { assertRevert } = require('./helpers/assertRevert');

var Crowdfund = artifacts.require("./Crowdfund.sol");
var Token = artifacts.require("./Token.sol");

contract('Ownable - Token', function (accounts) {

    const gasAmount = 6000000;
    const owner = accounts[0];
    const receivingAccount = accounts[1];
    const forwardAddress = accounts[7]
    const customer1 = accounts[2];
    const customer2 = accounts[3];
    const customer3 = accounts[4];
    const customer4 = accounts[5];
    const customer5 = accounts[6]

    const twentyEightDaysInSeconds = 2419200;
    const prices = [1000, 750, 500, 250] // 1*10^18 * 1000
    const epochs = [3, 4, 7, 14]
    const totalDays = 28
    const allocationAddresses = [forwardAddress, customer5, customer4, customer2, customer1, "0x0"]
    const allocationBalances = [
        50000000000000000000000,
        100000000000000000000000,
        50000000000000000000000,
        200000000000000000000000,
        100000000000000000000000,
        500000000000000000000000
    ]
    const allocationTimelocks = [0, twentyEightDaysInSeconds, 10 * 24 * 60 * 60, 10 * 24 * 60 * 60, 15 * 24 * 60 * 60, 0]
    const totalSupply_ = 1000000000000000000000000
    const withCrowdfund = false
    const crowdfundArgs = [
        owner,
        epochs,
        prices,
        receivingAccount,
        forwardAddress,
        totalDays,
        totalSupply_,
        withCrowdfund,
        allocationAddresses,
        allocationBalances,
        allocationTimelocks
    ];

    let ownable;

    beforeEach(async function () {
        // Crowdfund.class_defaults
        const crowdfund = await Crowdfund.new(
            ...crowdfundArgs, {
                from: owner
            }
        )

        ownable = await Token.at(await crowdfund.token());
    });

    it('should have an owner', async function () {
        let owner = await ownable.owner();
        assert.isTrue(owner !== 0);
    });

    it('changes owner after transfer', async function () {
        let other = accounts[1];
        await ownable.transferOwnership(other);
        let owner = await ownable.owner();

        assert.isTrue(owner === other);
    });

    it('should prevent non-owners from transfering', async function () {
        const other = accounts[2];
        const owner = await ownable.owner.call();
        assert.isTrue(owner !== other);
        await assertRevert(ownable.transferOwnership(other, { from: other }));
    });

    it('should guard ownership against stuck state', async function () {
        let originalOwner = await ownable.owner();
        await assertRevert(ownable.transferOwnership(null, { from: originalOwner }));
    });
});

contract('Ownable - CrowdFund', function (accounts) {
    const gasAmount = 6000000;
    const owner = accounts[0];
    const receivingAccount = accounts[1];
    const forwardAddress = accounts[7]
    const customer1 = accounts[2];
    const customer2 = accounts[3];
    const customer3 = accounts[4];
    const customer4 = accounts[5];
    const customer5 = accounts[6]

    const twentyEightDaysInSeconds = 2419200;
    const prices = [1000, 750, 500, 250] // 1*10^18 * 1000
    const epochs = [3, 4, 7, 14]
    const totalDays = 28
    const allocationAddresses = [forwardAddress, customer5, customer4, customer2, customer1, "0x0"]
    const allocationBalances = [
        50000000000000000000000,
        100000000000000000000000,
        50000000000000000000000,
        200000000000000000000000,
        100000000000000000000000,
        500000000000000000000000
    ]
    const allocationTimelocks = [0, twentyEightDaysInSeconds, 10 * 24 * 60 * 60, 10 * 24 * 60 * 60, 15 * 24 * 60 * 60, 0]
    const totalSupply_ = 1000000000000000000000000
    const withCrowdfund = false
    const crowdfundArgs = [
        owner,
        epochs,
        prices,
        receivingAccount,
        forwardAddress,
        totalDays,
        totalSupply_,
        withCrowdfund,
        allocationAddresses,
        allocationBalances,
        allocationTimelocks
    ];

    let ownable;

    beforeEach(async function () {
        ownable = await Crowdfund.new(
            ...crowdfundArgs, {
                from: owner
            }
        );
    });

    it('should have an owner', async function () {
        let owner = await ownable.owner();
        assert.isTrue(owner !== 0);
    });

    it('changes owner after transfer', async function () {
        let other = accounts[1];
        await ownable.transferOwnership(other);
        let owner = await ownable.owner();

        assert.isTrue(owner === other);
    });

    it('should prevent non-owners from transfering', async function () {
        const other = accounts[2];
        const owner = await ownable.owner.call();
        assert.isTrue(owner !== other);
        await assertRevert(ownable.transferOwnership(other, { from: other }));
    });

    it('should guard ownership against stuck state', async function () {
        let originalOwner = await ownable.owner();
        await assertRevert(ownable.transferOwnership(null, { from: originalOwner }));
    });
});

