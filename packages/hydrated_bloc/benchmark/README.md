# benchmark

## Conditions
Benchmarks made on `Samsung Galaxy S9+`, 16 iterations per test.  
Bloc count is number of `storageTokens` used.  
State size represents how much raw data takes (dismissing expense on serialization).  
I.e for state of 1KB, list of 256 ints will be saved. Strings are saved as strings.  
AES is AES

## Index table
### AES-ON

| Blocs | 4Bytes | 64Bytes | 256Bytes | 1KB | 4KB | 16KB       | 64KB       | 1MB        | 4MB |
|-------|--------|---------|----------|-----|-----|------------|------------|------------|-----|
| 1     | +      | +       | +        | +   | +   | +          | +          | +          | +   |
| 15    | +      | +       | +        | +   | +   | +          | +          | multi+hive | -   |
| 30    | +      | +       | +        | +   | +   | +          | multi+hive | only hive  | -   |
| 75    | +      | +       | +        | +   | +   | +          | multi+hive | only hive  | -   |
| 150   | +      | +       | +        | +   | +   | multi+hive | multi+hive | -          | -   |

### AES-OFF

| Blocs | 4Bytes | 64Bytes | 256Bytes | 1KB | 4KB | 16KB | 64KB | 1MB        | 4MB        |
|-------|--------|---------|----------|-----|-----|------|------|------------|------------|
| 1     | +      | +       | +        | +   | +   | +    | +    | +          | +          |
| 15    | +      | +       | +        | +   | +   | +    | +    | multi+hive | multi+hive |
| 30    | +      | +       | +        | +   | +   | +    | +    | multi+hive | multi+hive |
| 75    | +      | +       | +        | +   | +   | +    | +    | multi+hive | -          |
| 150   | +      | +       | +        | +   | +   | +    | +    | multi+hive | -          |

## Generalized graphs

<img src="./general.svg">

## Digest
> Pretty clear hive destroys.  
> &mdash; <cite>Felix</cite>  

And its hard to disagree with him🤪