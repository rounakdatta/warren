# warren

The container image [homelab.setup](https://github.com/rounakdatta/homelab.setup)
runs [Warren](https://github.com/doedja/warren) from. This repository is only the
packaging; the project is [doedja/warren](https://github.com/doedja/warren).

Upstream publishes release tarballs with checksums, not an image. The
`Dockerfile` downloads one pinned release, checks it against the sha256 recorded
in the file, and puts the single static binary into a `scratch` image: no shell,
no package manager, nothing fetched at runtime, runs as uid 65534.

```
ghcr.io/rounakdatta/warren:<version>      linux/amd64, linux/arm64
```

The image's entrypoint is `warren`, so `hub`, `node run` and `enroll` are its
arguments.

## Moving to a new release

1. In the `Dockerfile`, set `VERSION` and both sums. The sums are the release's
   `warren-v<version>-linux-x86_64.sha256` and `...-linux-arm64.sha256` assets
   (GitHub also shows each asset's digest, which is a second source to compare).
2. Run the **Image** workflow by hand. It builds and pushes nothing.
3. Tag `v<version>` and push the tag. That publishes the image. The workflow
   refuses a tag that disagrees with `ARG VERSION`.
4. Point homelab.setup at the new tag.

Warren is Apache-2.0; its license is copied into the image at
`/licenses/warren-LICENSE`.
