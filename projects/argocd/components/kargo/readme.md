# Kargo

https://docs.kargo.io/how-to-guides/installing-kargo

Integration with Holos:

1. We generate the admin password and JWT signing key using an ESO generator.
2. Credentials are stored in Secret `admin-credentials`
3. Helm values are imported to CUE.

Importing helm values:

```bash
helm inspect values oci://ghcr.io/akuity/kargo-charts/kargo > values.yaml
holos cue import --package holos --path 'Kargo: Values:' --outfile values.cue ./values.yaml
```
