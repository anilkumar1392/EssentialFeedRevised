
## Dependency Inversion Anatomy (High-level | Boundary | Low-level), Defining Inbox Checklists and Contract Specs to Improve Collaboration and Avoid Side-effect Bugs in Multithreaded Environments

## Process for mapping the requirments in hand and translating them in to tests.

Setting up Criteria for Any infrastructure implementation. (Eg, FileSystem, Coredata, realm)

Then Implementing iteratively in to produciton side
External clients implementing their interface must conform to these test cases.

Requirment feed store implementation.

- Retrieve
    - Empty cache
    - Non empty cache 
    - Non - empty cache twice returns same data (no side effects)
    - Error (if applicable, e.g, Invalid Data)

- Insert
    - To empty cache Stores data
    - To non empty cache overrides previous data with new data
    - Error (if applicable, if not write permission)
    
- Delete
    - Empty cache does nothing (Cache tays empty and does not fail)
    - Non empty cache leaves cache empty
    - Error (if applicable, if delete permission)
    
- Side effects must run serially to avoid race conditions.
