swaddle
=======

swaddle creates RPM, Deb and tarball packages using shell script

## Configuration

### Namespace `swaddle`

|Key|Kind|Validation|Default|Explanation|
|---|----|----------|-------|-----------|
|`architecture`|Value|Architecture|`all`|Use `all` or `noarch` for no architecture (converted as appropriate). Use `x86_64` or `amd64` for 64-bit AMD. Use others as appropriate. We do not currently allow use of multiple architectures|
|`vendor`|Value|NotEmpty|*none*|Usually either a company or an individual (eg an email address). Freeform.|
