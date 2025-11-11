target "docker-metadata-action" {}

variable "VERSION" {
  // renovate: datasource=github-releases depName=coredns/coredns
  default = "1.13.1"
}

variable "SOURCE" {
  default = "https://github.com/coredns/coredns"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${VERSION}"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}