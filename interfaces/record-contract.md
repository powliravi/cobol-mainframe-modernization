# API to Batch Record Contract

The upstream service emits JSON; a separate adapter validates and serializes
one event into one 80-byte `RECFM=FB` record in the `ADJIN` GDG. The file's
text bytes use EBCDIC CCSID 037. The amount is binary packed decimal and must
not be treated as display text by a text-mode transfer.

| Bytes | Length | Representation | Mapping |
| --- | ---: | --- | --- |
| 1-10 | 10 | EBCDIC display | `accountId`, left-zero-filled |
| 11-12 | 2 | EBCDIC display | `CR` for `CREDIT`, `DB` for `DEBIT` |
| 13-17 | 5 | Signed packed decimal, 9 digits, 2 decimals | `amount`, non-negative magnitude |
| 18-80 | 63 | Reserved bytes | Space-filled by adapter |

The `currency` must be `USD`. Reject missing/invalid account IDs, unsupported
adjustment types, negative amounts, amounts above `9999999.99`, and malformed
dates before writing the mainframe record. The sample COBOL currently handles
only account ID, adjustment type, and amount; the other API fields are boundary
metadata and are intentionally not added to the batch layout.

The output file is also `RECFM=FB,LRECL=80` in CCSID 037:

| Bytes | Length | Meaning |
| --- | ---: | --- |
| 1-10 | 10 | Account ID |
| 11-12 | 2 | Result: `OK`, `NF` (not found), or `ER` (rejected/error) |
| 13-24 | 12 | Updated balance as display `9(9).99`, or zero for non-OK |
| 25-80 | 56 | Spaces |

The downstream reconciliation step consumes this output as fixed-width text.