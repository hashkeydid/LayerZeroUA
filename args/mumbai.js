const DID_CONTRACT = "DidV2";
const {deployer,admin} = await getNamedAccounts();
logic = await deployments.get(DID_CONTRACT)
module.exports = [
    logic.address,
    admin,
    "0x"
  ];
  