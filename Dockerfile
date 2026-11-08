# syntax=docker/dockerfile:1

# Warren (https://github.com/doedja/warren) ships as one static musl binary.
# Upstream publishes checksummed release tarballs rather than an image, so this
# repackages a single pinned release into a scratch image: nothing is compiled
# here, nothing is downloaded when the container runs, and there is no shell.
#
# Moving to a new release is three edits that belong together -- VERSION and the
# two sums (each release carries them as *.sha256 assets) -- and then a
# v<VERSION> tag, which is what publishes. The workflow refuses a tag that
# disagrees with VERSION.
ARG VERSION=0.4.11
ARG SHA256_AMD64=9ad8e39824b4971a255a9bd9d33de97df76459061fa055afdbcf6a9b67155322
ARG SHA256_ARM64=aa2ebd4dd5deb468ee8ec4cc966f836b1acc03e6bc266573136e9928e1389e4a

# Runs on the build host's own architecture: only the downloaded asset differs
# per target, so the arm64 build involves no emulation.
FROM --platform=$BUILDPLATFORM alpine:3.24 AS fetch
ARG TARGETARCH
ARG VERSION
ARG SHA256_AMD64
ARG SHA256_ARM64
WORKDIR /out
RUN set -eu; \
    case "$TARGETARCH" in \
      amd64) asset=x86_64; sum="$SHA256_AMD64" ;; \
      arm64) asset=arm64;  sum="$SHA256_ARM64" ;; \
      *) echo "no Warren release for $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    base="https://github.com/doedja/warren/releases/download/v${VERSION}"; \
    wget -q -O warren.tar.gz "${base}/warren-v${VERSION}-linux-${asset}.tar.gz"; \
    echo "${sum}  warren.tar.gz" | sha256sum -c -; \
    tar -xzf warren.tar.gz warren; \
    wget -q -O LICENSE "https://raw.githubusercontent.com/doedja/warren/v${VERSION}/LICENSE"; \
    rm warren.tar.gz

FROM scratch
# Apache-2.0 asks that a redistributed binary travel with its license.
COPY --from=fetch /out/LICENSE /licenses/warren-LICENSE
COPY --from=fetch /out/warren /warren
USER 65534:65534
ENTRYPOINT ["/warren"]
