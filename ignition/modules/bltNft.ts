import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("bltNFTmodule", (m) => {

  const BLT_NFT = m.contract("BLT_NFT");



  return { BLT_NFT };
});
