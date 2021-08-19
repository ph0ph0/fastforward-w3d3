import RegistryInterface from Project.RegistryInterface
import RegistryService from Project.RegistryService

pub contract RegistryVotingContract: RegistryInterface {

    // --Overview
    // This contract that can be would be used to allow voting. There would be two roles
    // available; a Voter and a Vote Master. The Vote Master would create a proposal,
    // which has a proposalDescription, a proposalId and a proposalStatus (open, closed). They would also be able
    // to end voting on a proposal (change status to closed). In a future version, they could specify a timelimit
    // for the vote, beyond which the contract would automatically close the voting. In the 
    // 
    // --Road Blocks
    // 1) How do I 

    pub struct ProposalStatus {
        pub case Open
        pub case Closed
    }

    pub struct Proposal {
        pub let proposalId: UInt256
        pub let ownerAddress: Address
        pub let proposalDescription: String
        pub let proposalStatus: ProposalStatus
        // pub let expiry: UInt256?

        init(_proposalId: UInt256, _ownerAddress: Address _proposalDescription: String, _proposalStatus: ProposalStatus) {
            self.proposalId = _proposalId
            self.ownerAddress = _ownerAddress
            self.proposalDescription = _proposalDescription
            self.proposalStatus = _proposalStatus
        }

    }

    // Maps an address (of the customer/DappContract) to the amount
    // of tenants they have for a specific RegistryContract.
    access(contract) var clientTenants: {Address: UInt64}

    pub resource interface ITenant {

        // Both used to keep record of proposals a user has voted on
        pub var votersToProposals: {Address: [UInt256]}
        pub var proposalsToVoters: {UInt256: [Address]}

        // Record of the description of a proposal to the proposal itself
        pub var proposalsToDescriptions: {UInt256: String}

        // @dev proposalToVoteCount keeps track of the vote for each proposal.
        // {proposalId: voteCount}
        // We add the vote value (1 is for, -1 is against) to the voteCount value for the proposalId.
        // Since we know the number of votes (proposalsToVoters[proposalId].length),
        // we can work out how many for and how many against:
        // for = totalVotes - voteCount
        // against = |voteCount - totalVotes|
        pub var proposalToVoteCount: {UInt256: UInt32}

        pub var openProposals: [UInt256]
        pub var closedProposals: [UInt256]
        access(contract) fun assignVote(for proposal: Proposal, by: Address, vote: vote)

    }

    // Tenant
    //
    // Requirement that all conforming multitenant smart contracts have
    // to define a resource called Tenant to store all data and things
    // that would normally be saved to account storage in the contract's
    // init() function
    //
    pub resource Tenant {

        // @dev {ProposalId: {UserAddress: Vote}}
        pub var votes: {UInt256: {Address: UInt8}}

        access(contract) fun assignVote(for proposal: UInt256, by: Address, vote: vote): Bool {
            // Check that the address hasn't for this proposal voted yet
            // Check that the address of the caller matches the address passed in?
            // Update the votes dictionary

            // return true if user can vote
        }

        init() {

        }
    }

    // instance
    // instance returns an Tenant resource.
    //
    pub fun instance(authNFT: &RegistryService.AuthNFT): @Tenant {
        let clientTenant = authNFT.owner!.address
        if let count = self.clientTenants[clientTenant] {
            self.clientTenants[clientTenant] = self.clientTenants[clientTenant]! + (1 as UInt64)
        } else {
            self.clientTenants[clientTenant] = (1 as UInt64)
        }

        return <-create Tenant()
    }

    // getTenants
    // getTenants returns clientTenants.
    //
    pub fun getTenants(): {Address: UInt64} {
        return self.clientTenants
    }


    // @dev allows users to vote on a proposal
    pub resource VoteEnabler {

        pub fun getOpenProposals(): [String] {

        }

        pub fun getClosedProposals(): [String] {

        }

        pub fun castVote(tenant: &Tenant{ITenant}, proposal: UInt256, vote: UInt8): Bool {
            if (vote != 1 || vote != -1) {
                return false
            }
            tenant.assignVote(for proposal, by: Address, vote: vote): Bool
            // Mint NFT and return success?
            return true

        }

    }

    // @dev allows the vote master to control the voting
    pub resource VoteMaster {
        pub fun createNewVoteProposal(tenant: &Tenant{ITenant}, proposalDescription: String, expiry: UInt256?): UInt256 {
            // Create a Proposal object

        }
        pub fun endVotingOnProposal(tenant: &Tenant{ITenant}, proposalId: proposalId ): Bool {
            // returns success/failure
        }
        pub fun getVotesForProposal(tenant: &Tenant{ITenant}, proposalId: proposalId): UInt32 {
            // returns number of votes for a given proposalId
        }

    }

    // Named Paths
    //
    pub let TenantStoragePath: StoragePath
    pub let TenantPublicPath: PublicPath

    init() {
        // Initialize clientTenants
        self.clientTenants = {}

        // Set Named paths
        self.TenantStoragePath = /storage/RegistrySampleContractTenant
        self.TenantPublicPath = /public/RegistrySampleContractTenant
    }
}