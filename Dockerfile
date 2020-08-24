FROM golang:1.11 as builder

WORKDIR /go/src/github.com/maistra/istio-operator

COPY . .

WORKDIR /go/src/github.com/maistra/istio-operator/cmd/manager

RUN GOOS=linux GOARCH=ppc64le CGO_ENABLED=0 go build -o $GOPATH/bin/istio-operator

FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

LABEL com.redhat.component="maistra-istio-operator"
LABEL name="maistra/istio-ubi8-operator"
LABEL version="1.0.0"
LABEL istio_version="1.1.11"
LABEL summary="Red Hat Istio Operator OpenShift container image"
LABEL description="Red Hat Istio Operator OpenShift container image"
LABEL io.k8s.display-name="Red Hat Istio Operator"
LABEL io.openshift.tags="istio"
LABEL io.openshift.expose-services=""
LABEL maintainer="Istio Feedback <istio-feedback@redhat.com>"
ENV container="oci"
ENV ISTIO_VERSION=1.1.11

COPY --from=builder /go/bin/istio-operator /usr/local/bin/istio-operator
COPY --from=maistra/istio-ubi8-operator:1.0.0 /usr/local/share/istio-operator/ /usr/local/share/istio-operator/

RUN sed -i 's/openshift\//registry\.access\.redhat\.com\/openshift3\//' /usr/local/share/istio-operator/helm/1.1.0/istio/charts/prometheus/templates/deployment.yaml
RUN sed -i 's/openshift\//registry\.access\.redhat\.com\/openshift3\//' /usr/local/share/istio-operator/helm/1.1.0/istio/charts/grafana/templates/deployment.yaml

WORKDIR /tmp/

ENTRYPOINT [ "/usr/local/bin/istio-operator"]
