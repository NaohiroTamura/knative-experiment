# Hello World + Outbound network access - Prolog sample

```sh
$ export DOCKER_HUB_ACCOUNT=your_account_name

$ docker build -t ${DOCKER_HUB_ACCOUNT}/helloworld-prolog .

$ docker push ${DOCKER_HUB_ACCOUNT}/helloworld-prolog

$ envsubst < helloworld.yml | kubectl apply -f -

$ kubectl get pod
```

```sh
$ export IP_ADDRESS=$(kubectl get node  -o 'jsonpath={.items[0].status.addresses[0].address}'):$(kubectl get svc knative-ingressgateway -n istio-system   -o 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')

$ export HOST_URL=$(kubectl get services.serving.knative.dev helloworld-prolog  -o jsonpath='{.status.domain}')

$ curl -H "Host: ${HOST_URL}" http://${IP_ADDRESS}
Hello World: SWI Prolog Sample v1!
Title: Google
```
