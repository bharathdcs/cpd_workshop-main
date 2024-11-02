cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-router
  namespace: workshop
spec:
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          policy-group.network.openshift.io/ingress: ""
  - from:
    - namespaceSelector:
        matchLabels:
          app: test-ingress
  - from:
    - podSelector: {}
  podSelector: {}
  policyTypes:
  - Ingress
EOF