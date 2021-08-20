import RegistryInterface from Project.RegistryInterface
import RegistryService from Project.RegistryService

pub contract RegistryVotingContract: RegistryInterface {

    // --Overview
    // This contract that can be would be used to allow voting. There would be two roles
    // available; a Voter and a Vote Master. The Vote Master would create a proposal,
    // which has a proposalDescription, a proposalId and a proposalStatus (open, closed). It also has a votePool, 
    // which are all the addresses that are allowed to vote on the proposal. The Vote Master would also be able
    // to end voting on a proposal (change status to closed). In a future version, they could specify a timelimit
    // for the vote, beyond which the contract would automatically close the voting. 
    // A vote for is represented by 1, a vote against is represented by -1.
    // --Road Blocks
    // 1) I haven't used any tokens?
    // 2) Need to revise access control modifiers
    // 3) Is my architecture wrong? How do we allocate both Vote Master and Voter resources?
    // 4) How do we assign a proposalId to the Proposal?

    pub struct ProposalStatus {
        pub case isOpen
        pub case isClosed
    }

    pub struct Proposal {
        pub let proposalId: UInt256
        pub let ownerAddress: Address
        pub let proposalDescription: String
        pub let proposalStatus: ProposalStatus
        // votePool: Pool of voters allowed to vote
        pub let votePool: [Address]
        pub let totalVotes: Int32
        // voteCount: Sum of all votes. If positive, majority in favour, if negative, majority against.
        pub let voteSum: Int32
        // votedOnBy: Addresses that have voted
        pub let votedOnBy: [Address]
        // pub let expiry: UInt256?



        init(_proposalId: UInt256, _ownerAddress: Address, _proposalDescription: String, _proposalStatus: ProposalStatus, _votePool: [Address]) {
            self.proposalId = _proposalId
            self.ownerAddress = _ownerAddress
            self.proposalDescription = _proposalDescription
            self.proposalStatus = ProposalStatus.isOpen
            self.votePool = _votePool
            self.totalVotes = 0
            self.voteSum= 0
            self.votedOnBy = []

        }

    }

    // Maps an address (of the customer/DappContract) to the amount
    // of tenants they have for a specific RegistryContract.
    access(contract) var clientTenants: {Address: UInt64}

    pub resource interface ITenantVoter {

        access(contract) fun assignVote(for voter: Address, to: , vote: vote): Bool

    }

    pub resource interface ITenantVoteMaster {

        pub var allProposals: [Proposal]
        pub var openProposals: [Proposal]
        pub var closedProposals: [Proposal]

        access(contract) fun getTotalNoOfProposals(): Int
        access(contract) fun getAllProposals(): [Proposal]
        access(contract) fun getOpenProposals(): [Proposal]
        access(contract) fun getClosedProposals(): [Proposal]

        access(contract) fun getProposal(proposalId: UInt256): Proposal

    }

    // Tenant
    //
    // Requirement that all conforming multitenant smart contracts have
    // to define a resource called Tenant to store all data and things
    // that would normally be saved to account storage in the contract's
    // init() function
    //
    pub resource Tenant {

        pub var openProposals: [Proposal]
        pub var closedProposals: [Proposal]

        access(contract) fun getTotalNoOfProposals(): Int {
            let allProposals = openProposals.concat(closedProposals)
            return allProposals.length
        }

        access(contract) fun getAllProposals(): [Proposal] {
            return openProposals.concat(closedProposals)
        }

        access(contract) fun getOpenProposals(): [Proposal] {
            return openProposals
        }

        access(contract) fun getClosedProposals(): [Proposal] {
            return closedProposals
        }

        access(contract) fun assignVote(for proposalId: UInt256, voterAddress: Address, vote: Int8): Bool {
            // Update the proposal votes
            for proposal in openProposals {
                if proposalId == proposal.proposalId {
                    // Check that the address hasn't voted for this proposal yet and is allowed to vote on it
                    if (proposal.votedOnBy.contains(voterAddress) || !proposal.votePool.contains(voterAddress)) {
                        return false
                    }
                    proposal.voteSum  = proposal.voteSum + vote
                    proposal.votedOnBy.append(voterAddress)
                    return true
                }
            }
            return false
        }

        init() {
            self.openProposals = []
            self.closedProposals = []
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
    pub resource VoterResource {

        pub fun getOpenProposals(): [String] {

        }

        pub fun getClosedProposals(): [String] {

        }

        pub fun castVote(tenant: &Tenant{ITenant}, proposal: UInt64, vote: UInt8): Bool {
            if (vote != 1 || vote != -1) {
                return false
            }
            tenant.assignVote(for proposal, by: Address, vote: vote): Bool
            // Mint NFT and return success?
            return true

        }

    }

    // @dev allows the vote master to control the voting
    pub resource VoteMasterResource {
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