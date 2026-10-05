# Account Adjustment Batch Demo

This synthetic sample models an upstream account-adjustment API feeding a
mainframe batch program, a DB2 customer-balance table, and a downstream
reconciliation step. It is intended for modernization and dependency-analysis
demos, not production use.

## Flow

1. `interfaces/upstream-adjustment.json` represents an upstream API request.
2. An external adapter validates the request, maps it using
   `interfaces/record-contract.md`, and writes an 80-byte fixed-block file to
   the `ADJIN` GDG. Text fields are EBCDIC CCSID 037; the amount field is packed
   decimal. The JSON-to-record adapter is a boundary contract, not included
   executable software.
3. `jcl/ADJDAILY.jcl` invokes `jcl/ADJBATCH.proc`. The COBOL program reads each
   adjustment, reads the matching DB2 customer row, applies a credit or debit,
   updates DB2, and writes a fixed-width outcome record.
4. The dependent `REPORT` step checks the batch output and produces a small
   reconciliation report.

## Source members

- `cobol/ADJBAT01.cbl`: batch program, sequential file I/O, embedded DB2 SQL.
- `cobol/copy/ADJREC.cpy`: input layout with `REDEFINES` and `COMP-3`, plus
  output layout.
- `cobol/dclgen/CUSTBAL.cpy`: DCLGEN-style table declaration and host structure.
- `jcl/ADJBATCH.proc`: parameterized batch execution PROC.
- `jcl/ADJDAILY.jcl`: GDG allocation, PROC invocation, and dependent report.
- `interfaces/record-contract.md`: API-to-mainframe record mapping.

## Assumptions

- The illustrative DB2 table is `DEMO.CUSTOMER_BALANCE`, keyed by a 10-byte
  account ID, with a `DECIMAL(9,2)` balance and a one-byte active indicator.
- Adjustment codes are `CR` (credit) and `DB` (debit); the signed packed amount
  is supplied as a non-negative magnitude.
- The demo records are fixed-block, 80 bytes. The packed field occupies bytes
  13-17; the remaining 63 bytes are reserved.
- The output records are fixed-block, 80-byte EBCDIC text records.
- JCL product names, compiler options, DB2 plan/package names, subsystem, and
  site-specific dataset conventions are placeholders to adapt locally.

The sample deliberately has no credentials, real customer data, or live API
integration.