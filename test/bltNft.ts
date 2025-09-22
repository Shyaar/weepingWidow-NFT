import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("BLT_NFT", () => {
  let bltNft: any;
  let owner: any, addr1: any, addr2: any;

  beforeEach(async () => {
    [owner, addr1, addr2] = await ethers.getSigners();
    bltNft = await ethers.deployContract("BLT_NFT");
  });

  it("should set the deployer as the Admin", async () => {
    expect(await bltNft.admin()).to.equal(owner.address);
  });

  it("should mint 5 nfts to contract at deployment", async () => {
    expect(await bltNft.balanceOf(bltNft.target)).to.equal(5);
  });

  it("should return correct owner for minted tokens", async () => {
    for (let i = 0; i < 5; i++) {
      expect(await bltNft.ownerOf(i)).to.equal(bltNft.target);
    }
  });

  it("should generate correct tokenURI", async () => {
    const uri = await bltNft.tokenURI(1);
    expect(uri).to.equal(
      "ipfs://QmYK1ohUjyhBAqBs4FcpZ6z2Hd95ihU7E91r2qJM42tagf/1.json"
    );
  });

  it("should allow approve and getApproved", async () => {
    await bltNft.connect(owner).approve(addr1.address, 0);
    expect(await bltNft.getApproved(0)).to.equal(addr1.address);
  });

  it("should allow setApprovalForAll and isApprovedForAll", async () => {
    await bltNft.connect(owner).setApprovalForAll(addr1.address, true);
    expect(await bltNft.isApprovedForAll(owner.address, addr1.address)).to.equal(
      true
    );
  });

  it("should allow transfer of NFT if caller is owner", async () => {

    await bltNft.connect(owner).approve(addr1.address, 0);

    
    await bltNft.connect(addr1).transferFrom(bltNft.target, addr2.address, 0);

    expect(await bltNft.ownerOf(0)).to.equal(addr2.address);
    expect(await bltNft.balanceOf(addr2.address)).to.equal(1);
  });

  it("should emit Transfer event on transfer", async () => {
    await bltNft.connect(owner).approve(addr1.address, 1);

    await expect(
      bltNft.connect(addr1).transferFrom(bltNft.target, addr2.address, 1)
    )
      .to.emit(bltNft, "Transfer")
      .withArgs(bltNft.target, addr2.address, 1);
  });

  it("should revert if transferring to address(0)", async () => {
    await bltNft.connect(owner).approve(addr1.address, 2);

    await expect(
      bltNft
        .connect(addr1)
        .transferFrom(bltNft.target, ethers.ZeroAddress, 2)
    ).to.be.revertedWith("Invalid address to transfer to!");
  });

  it("should revert tokenURI for nonexistent token", async () => {
    await expect(bltNft.tokenURI(999)).to.be.revertedWith(
      "Token does not exist"
    );
  });
});
