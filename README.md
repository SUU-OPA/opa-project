# Środowiska Udostępniania Usług
## Temat projektu - Open Policy Agent
#### Autorzy
- Jakub Radek
- Edyta Paruch
- Andrzej Starzyk
- Roksana Cieśla

## Introduction
Celem projektu jest przedstawienie możliwości technologii silnika Open Policy Agent - OPA w kontekście integracji z istniejącą aplikacją. W tym sprawozdaniu skupimy się na analizie procesu integracji OPA z istniejącą już aplikacją, obejmując projektowanie, implementację i ocenę sensowności oraz efektywności takiego rozwiązania. 
Poprzez praktyczne zastosowanie OPA w kontekście rzeczywistych aplikacji, będziemy badać potencjalne korzyści i wyzwania związane z jego wdrożeniem. W ramach projektu szczególną uwagę poświęcimy zrozumieniu mechanizmów działania OPA oraz jego możliwości konfiguracyjnych w kontekście konkretnych przypadków użycia. Analiza ta pozwoli nam na lepsze zrozumienie roli, jaką może odegrać OPA w zapewnianiu bezpieczeństwa oraz kontroli dostępu w środowiskach aplikacji.

## Theoretical background/technology stack
### Polityki
Polityka to zbiór zasad, zgodnie z którymi jest zarządzany pewien software'owy serwis. Mogą dotyczyć ruchu sieciowego, dostępu do serwerów, uprawnień użytkowników itp. Zazwyczaj są na sztywno zapisane w plikach danego serwisu.
### OPA
Celem Open Policy Agent jest oddzielenie zarządzania politykami od serwisu. Oznacza to, że definicje polityk są umieszczone na osobnym serwerze, który udostępnia REST API. Za jego pomocą serwisy mogą wysyłać zapytania o to, czy podejmowane działania są zgodne z przyjętymi politykami. 
### Definiowanie polityk
OPA przechowuje strukturę całego systemu w formacie JSON. Dzięki temu może łatwo sprawdzić, czy stan systemu jest zgodny z polityką. Te z kolei są definiowane za pomocą deklaratywnego języka REGO. Każda definicja składa się z pewnych wyrażeń logicznych. Jeśli wszystkie są prawdziwe, to założenia polityki są spełnione.
### Integracja z Kubernetes
OPA można wdrożyć jako Admission Controller, który modyfikuje zapytania docierające do API Serwera Kubernetes. W ten sposób gdy jakikolwiek obiekt jest tworzony, modyfikowany lub usuwany API Serwer wysyła opis tej sytuacji jako żądanie do OPA. Ten serwis z kolei traktuje to dane w formacie JSON podobnie jak opisaną powyżej strukturę systemu - sprawdza zgodność z politykami i odsyła odpowiedź. API Serwer podejmuje na tej podstawie decyzję o przeprowadzeniu pewnej operacji lub w przeciwnym wypadku obsługuje odmowę. Wdrożenie tego rozwiązania polega na napisaniu kodu polityk, stworzeniu serwera OPA i wdrożeniu go do kubernetes.

Innym rozwiązaniem jest OPA Gatekeeper. Podobnie jak powyższe rozwiązanie pozwala na rozdzielenie polityk od serwera API i realizuje jako admission controller modyfikujący żądania. Jednak definiowanie polityk polega na konfigurowaniu zamiast kodowania, a rozstrzyganie zgodności z politykami bierze pod uwagę cały system, nie tylko pojedyncze żądanie. Z uwagi na fakt, że jest to osobny projekt, choć powiązany z OPA, traktujemy to rozwiązanie jak ewentualny kierunek rozwoju case study.
![kubernetes-admission-flow.png](images%2Fkubernetes-admission-flow.png)

## Case study concept description
Integracja OPA z Kubernetesem jest jednym z głównych zastosowań tego narzędzia. Z tego powodu celem case study jest zaprezentowanie możliwości OPA w środowisku Kubernetes. Realizacja tego projektu zakłada zdefiniowanie polityk OPA dla przykładowej aplikacji w kontenerze na Kubernetesie. Polityki te pomogą zarządzać aplikacją i pokażą rozwiązania potencjalnych problemów wiążących się z udostępnianiem takiej aplikacji.

Do realizacji case study wykorzystana zostanie aplikacja biura turystycznego, powstała podczas prac nad projektem inżynierskim jednego z członków zespołu. Aplikacja realizuje funkcjonalności związane z proponowaniem wycieczek, posiada system logowania, zapisywania oraz wczytywania wycieczek. Nie jest ona jednak w pełni dostosowana do publicznego udostępnienia. Zaistniałymi problemami są między innymi potencjalnie zbyt duża liczba użytkowników korzystających z aplikacji jednocześnie, co może powodować niepożądane zachowania. Problem ten można zmniejszyć, tworząc kilka serwerów aplikacji i ustalając odpowiednie polityki dostępu, osobny dostęp dla pracowników biura, deweloperów aplikacji i użytkowników zewnętrznych oraz zapewnienie load balacingu pomiędzy tymi serwerami. Inny scenariusz wykorzystania polityk może dotyczyć tworzenia i usuwania kontenerów na potrzeby różnych konkretnych grup użytkowników oraz ich autoryzacji - przykładowo wymuszenie zalogowania, czy ograniczenie oferowanych funkcjonalności aplikacji dla innych grup użytkowników.

Integracja aplikacji z OPA zostanie wykonana przy użyciu standardowego kube-mgmt - komend i skryptów definiujących zasoby, polityki oraz ich wdrażanie w systemie. 

## Solution architecture
### Architektura aplikacji biura turystycznego na Kubernetes
Aplikacja biura turystycznego będzie działać w oparciu o środowisko Kubernetes, wykorzystując kontenery do izolacji oraz skalowalności. Architektura ta będzie obejmować:
- Kontenery aplikacyjne: Kontenery zawierające aplikację biura turystycznego oraz jej składowe.
- Serwery API: Serwisy API będą udostępniały funkcjonalności aplikacji.

Pozostałe funkcjonalności związane z dostępem do aplikacji, jak i jej utrzymywaniem są rozwiązane poprzez Open Policy Agent, co zostało opisane poniżej.

### Integracja OPA jako Admission Controller
OPA zostanie zintegrowane z Kubernetesem jako Admission Controller, co umożliwi kontrolę nad żądaniami tworzenia, modyfikowania oraz usuwania zasobów aplikacji w klastrze Kubernetes. Architektura integracji OPA obejmie:
- Serwer OPA: OPA będzie działać jako serwer REST API, który będzie odpowiedzialny za ocenę zgodności żądań do klastra Kubernetes ze zdefiniowanymi politykami.
- Polityki OPA: Zdefiniowane polityki będą określały, jakie operacje są dozwolone, a jakie nie, na podstawie analizy żądań do klastra Kubernetes. Polityki te stworzone zostaną oddzielnie od aplikacji i przechowywane będą na serwerze OPA.
- Integracja z Kubernetesem: OPA będzie zintegrowane z API serwera Kubernetes poprzez mechanizm Admission Control, który umożliwi przekazywanie żądań do serwera OPA, weryfikację ich poprzez polityki OPA i następnie jeśli zostaną zaakceptowane, przekazanie do Kubernetesa.

### Schemat architektury
![Architektura aplikacji.png](images%2FArchitektura%20aplikacji.png)

W architekturze widocznej na powyższym rysunku aplikacja biura turystycznego działa na klastrze Kubernetes i jest zintegrowane z OPA jako Admission Controller, który kontroluje żądania wchodzące do klastra. Polityki OPA definiują, które operacje są dozwolone, a które nie na podstawie analizy żądań do klastra Kubernetes.

### Implementacja polityk
Wykorzystanie polityk może obejmować wszelkie operacje na zasobach. W kontekście prezentowanego case study pojawia się przechowywanie różnorodnych zasobów, ich replikacja i tworzenie namespace'ów, logicznie je grupujących. Funkcjonuje ponadto load balancing zapewniony przez serwis ingress. Z kolei same serwisy aplikacji, zdeployowane na kubernetes potrzebują autoryzacji. Przykładowymi zastosowaniami polityk mogą być zatem:

-przyzwolenie na tworzenie podów zawierających obrazy kontenerów tylko z konkretnych rejestrów

-zablokowanie pewnych operacji w wybranych namespace'ach.

-polityki regulujące tworzenie serwisów ingress - przydział odpowiednich hostów do namespace'ców, przydział każdego hosta do jednego ingressu 

-autoryzacja użytkowników, dopuszzczenie do funkjonalności konkretnego serwisu

```rego
package admission

import future.keywords

import rego.v1
import future.keywords

default deny = true

deny := false if {
    not any_wrong_registry
}

any_wrong_registry if {
    some container
    input_containers[container]
	not startswith(container.image, "foo.com/")
}

input_containers contains container if {
	container := input.request.object.spec.containers[_]
}
```

```rego
#przykład pochodzi z dokumentacji OPA
package kubernetes.admission

import rego.v1

import data.kubernetes.namespaces

operations := {"CREATE", "UPDATE"}

deny contains msg if {
	input.request.kind.kind == "Ingress"
	operations[input.request.operation]
	host := input.request.object.spec.rules[_].host
	not fqdn_matches_any(host, valid_ingress_hosts)
	msg := sprintf("invalid ingress host %q", [host])
}

valid_ingress_hosts := {host |
	allowlist := namespaces[input.request.namespace].metadata.annotations["ingress-allowlist"]
	hosts := split(allowlist, ",")
	host := hosts[_]
}

fqdn_matches_any(str, patterns) if {
	fqdn_matches(str, patterns[_])
}
```

Wdrożenie polityk odbywa się poprzez stworzenie servera  OPA API. W tym celu należy przygotować kody polityk, zbudować bundle serwera OPA, na jego podstawie stworzyć serwer

W przypadku polityk dodtyczących kubernetes trzeba jeszczezdeployować serwer jako admission controller. Warto dodać, że przy tym można zadbać o bezpieczeństwo kominikacji wykorzystując szyfrowanie komunikacji.

Kwestia wykorzystania OPA do autoryzacji wymaga innego podejścia do Policy Agenta. Polega ono na odpytywaniu serwera REST API OPA, co do zgodności żądań HTTP z politykami.


## Environment configuration description
Wersja demonstracyjna działania systemu OPA wykorzystywać będzie system Windows 10 wraz z WSL 2 (Windows Subsystem for Linux) oraz Docker Desktop, który umożliwi lokalne uruchomienie oraz zarządzanie kontenerami w środowisku Kubernetes na potrzeby uruchomienia aplikacji, oraz zintegrowanie jej z systemem OPA.

## Installation method

### Minikube i Kubernetes

Do instalacji będzie wykorzystane oprogramowanie Minikube, które umożliwia lokalne uruchomienie klastra Kubernetes.

- Pobierz i zainstaluj Minikube
- Zainstaluj Kubernetes CLI (kubectl)
- Uruchom Minikube
```rego
minikube start
```

### Wdrożenie aplikacji

- Skopiuj plik deploymentu dla aplikacji (’dep3.yaml’)
-  Przejdź do katalogu, w którym znajduje się plik 'dep3.yaml' i wpisz komendę:
```rego
kubectl apply -f .\dep3.yaml
```
- Sprawdź status serwisu, uruchamiając:
```rego
minikube service flask-app-service
```
- To polecenie otworzy przeglądarkę z adresem URL, pod którym będzie dostępna aplikacja

Aby usunąć konfigurację wyjdź z widoku serwisów za pomocą Ctl+C, następnie:
```rego
    kubectl delete -f .\dep3.yaml
    minikube stop
```

### OPA jako Admission Controller
W oparciiu o dokumentację https://www.openpolicyagent.org/docs/latest/kubernetes-tutorial/
- Włącz dodatek Ingress w Minikube
```rego
minikube addons enable ingress
```
- Utwórz namespace, w którym będzie działać OPA
```rego
kubectl create namespace opa
kubectl config set-context opa-tutorial --user minikube --cluster minikube --namespace opa
kubectl config use-context opa-tutorial
```
- Wygeneruj certfikaty TLS
```rego
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -sha256 -key ca.key -days 100000 -out ca.crt -subj "/CN=admission_ca"
```
- Wygeneruj klucz TLS i certyfikat dla OPA
```rego
cat >server.conf <<EOF
[ req ]
prompt = no
req_extensions = v3_ext
distinguished_name = dn

[ dn ]
CN = opa.opa.svc

[ v3_ext ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
subjectAltName = DNS:opa.opa.svc,DNS:opa.opa.svc.cluster,DNS:opa.opa.svc.cluster.local
EOF

openssl genrsa -out server.key 2048
openssl req -new -key server.key -sha256 -out server.csr -extensions v3_ext -config server.conf
openssl x509 -req -in server.csr -sha256 -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 100000 -extensions v3_ext -extfile server.conf
```
- Utwórz secret, aby przechowywać poświadczenia TLS dla OPA
```rego
kubectl create secret tls opa-server --cert=server.crt --key=server.key --namespace opa
```
- Przejdź do katalogu z politykami, zbuduj i opublikuj OPA Bundle
```rego
cat > .manifest <<EOF
{
    "roots": ["kubernetes/admission", "system"]
}
EOF
opa build -b .
```
- Uruchom serwer Nginx do obsługi OPA bundle
```rego
docker run --rm --name bundle-server -d -p 8888:80 -v ${PWD}:/usr/share/nginx/html:ro nginx:latest
```
- Przejdź do katalogu zawierającego plik 'admission-controller.yaml' i wdróż OPA jako Admission Controller
```rego
kubectl apply -f admission-controller.yaml
```
- Zarejestruj OPA jako Admission Controller
```rego
kubectl apply -f webhook-configuration.yaml
```
## How to reproduce - step by step
### Przygotowanie obrazu aplikacji

- Przejdź od folderu z kodem aplikacji, do folderu app, w którym znajduje się Dockerfile
- wykonaj komendy:
```rego
docker build -t flask-app:latest.
```
- w celu przesłania do publicznego repozytorium na DockerHub zaloguj się za pomocą komędu docker login
```rego
docker tag flask-app dockerhub username/flask-app
docker push dockerhub username/flask-app
```

### Konfiguracja OPA
Na podstawie dokumentacji https://www.openpolicyagent.org/docs/latest/kubernetes-tutorial/
- pliku image-allowlist.rego w folderze policies przekopiuj kod
```rego
package kubernetes.admission

import rego.v1

import data.kubernetes.ingress

deny contains msg if {
    some container
    input_containers[container]
    not startswith(container.image, "docker.io/andrzejstarzyk/suu_")
    image := container.image
    msg := sprintf("invalid image registry %q", [image])
}

input_containers := {container |
    container := input.request.object.spec.template.spec.containers[_]
}
```
```rego
opa build -b . lub opa\_windows\_amd64 build -b .
```
```rego
docker run --rm --name bundle-server -d -p 8888:80 -v \${PWD}:/usr/share/nginx/html:ro nginx:latest
```
```rego
kubectl apply -f admission-controller.yaml
```
```rego
kubectl label ns kube-system openpolicyagent.org/webhook=ignore
```
```rego
kubectl label ns opa openpolicyagent.org/webhook=ignore
```
```rego
kubectl apply -f webhook-configuration.yaml
```
```rego
kubectl create -f production-namespace.yaml
```
```rego
kubectl apply -f dep2.yaml -n production
```
```rego
kubectl apply -f dep3.yaml -n production
```
- Próba deployowania aplikacji z obazem pochodzącym z repozytorium niewymienionego w politykach poskutkuje wypisaniem komunikatu podobnego do
```rego
"Error from server: error when creating "dep2.yaml": admission webhook "validating-webhook.openpolicyagent.org" denied the request: invalid image registry "docker.io/andrzejstarzyk/suu\_project\_app:latest""
```

### Zmiana polityk

Plik .rego zawierają polityki, które można edytować, np. zmienić wymaganą nazwę repozytorium z obrazem. Po takiej zmianie należy wykonać następujące polecenia
```rego
kubectl apply -f webhook-configuration.yaml
```
```rego
kubectl delete apply -f admission-controller.yaml 
```
- zakończ pracę bundle-server'a i wykonaj w terminalu polecenia
```rego
opa\_windows\_amd64 build -b .
```
```rego
docker run --rm --name bundle-server -d -p 8888:80 -v \${PWD}:/usr/share/nginx/html:ro nginx:latest
```
```rego
kubectl apply -f admission-controller.yaml
```
```rego
kubectl apply -f webhook-configuration.yaml 
```
```rego
kubectl apply -f dep3.yaml -n production
```

### Infrastructure as Code approach

W podejściu Infrastructure as Code (IaC) dążymy do automatyzacji i zarządzania infrastrukturą aplikacji za pomocą kodu. W ramach naszego projektu wdrażane zostają kluczowe aspekty IaC, zarówno  dla Open Policy Agent w roli Admission Controller'a, jak i dla samej aplikacji biura turystycznego.

Polityki **Open Policy Agent** są definiowane za pomocą deklaratywnego języka REGO, co pozwala na precyzyjne określenie dozwolonych operacji w infrastrukturze. Definiowane polityk za pomocą kodu źródłowego ułatwia ich zarządzanie i wersjonowalność. Szczegółowy proces wdrażania systemu OPA do infrastruktury został zaprezentowany w rozdziale [6.3](#opa-jako-admission-controller). Przykład wdrażania polityki został przedstawiony w rozdziale [7.2](#konfiguracja-opa). Wszelkie zmiany w tak zdefiniowanych politykach są proste, a ich realizację w systemie można wykonać, postępując zgodnie z rozdziałem [7.3](#zmiana-polityk).

Podobnie zarządzanie i wdrażanie **aplikacji biura turystycznego** jest ułatwione, dzięki zastosowaniu zasad IaC. Konfiguracja aplikacji (deployment i serwis) jest zdefiniowana za pomocą pliku YAML (dep3.yaml):
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
      - name: flask
        image: docker.io/andrzejstarzyk/suu_project_app:latest
        ports:
        - containerPort: 5000
---
apiVersion: v1
kind: Service
metadata:
  name: flask-app-service
spec:
  selector:
    app: flask-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: LoadBalancer
```

Takie podejście ułatwia kontrolę zmian i proste wdrażanie nowych wersji aplikacji. Obraz aplikacji został przygotowany zgodnie z podpunktem [7.1](#przygotowanie-obrazu-aplikacji), i jest przechowywany na repozytorium Docker Hub. Dzięki takiemu podejściu można łatwo powrócić do poprzednich wersji aplikacji w razie potrzeby. Dokładny proces wdrażania jej pokazano w rozdziale [6.2](#wdrożenie-aplikacji).


## Autoryzacja z OPA
Oprócz opisanego powyżej zarządzania zasobami Kubernetes Open Policy Agent może zostać wykorzystany do autoryzacji. 
W tym celu należy stworzyć serwer HTTP, do którego kierowane są zapytania dotyczące polityk dostępowych. 
Z kolei aplikacja powinna wysyłać zapytania do tego serwera przed udostępnianiem zasobów. 
Poniżej zostało opisane stworzenie serwera na Dockerze i kod aplikacji odpowiadający za autoryzację.

## Konfiguracja

- Stwórz plik docker-compose.yaml z następującą zawartością:
```rego
version: '2'
services:
  opa:
    image: openpolicyagent/opa:0.65.0
    ports:
    - 8181:8181
    # WARNING: OPA is NOT running with an authorization policy configured. This
    # means that clients can read and write policies in OPA. If you are
    # deploying OPA in an insecure environment, be sure to configure
    # authentication and authorization on the daemon. See the Security page for
    # details: https://www.openpolicyagent.org/docs/security.html.
    command:
    - "run"
    - "--server"
    - "--log-format=json-pretty"
    - "--set=decision_logs.console=true"
    - "--set=services.nginx.url=http://bundle_server"
    - "--set=bundles.nginx.service=nginx"
    - "--set=bundles.nginx.resource=wibit_auth_policies/bundle.tar.gz"
    depends_on:
    - bundle_server
  api_server:
    image: openpolicyagent/demo-restful-api:0.3
    ports:
    - 5000:5000
    environment:
    - OPA_ADDR=http://opa:8181
    - POLICY_PATH=/v1/data/httpapi/authz
    depends_on:
    - opa
  bundle_server:
    image: nginx:1.20.0-alpine
    ports:
    - 8888:80
    volumes:
    - ./wibit_auth_policies:/usr/share/nginx/html/wibit_auth_policies
```
- Stwórz folder wibit_auth_policies, a w nim plik auth.rego

```rego
package httpapi.authz

import rego.v1

options := {"quick-trip": ["Marek"], "survey": [], "file": []}

methods = ["GET", "POST"]

default allow := false

# Allow all users to get trip with survey.
allow if {
	methods[_] == input.method
	input.option == "survey"
}

# Allow selected office workers to generate quick trip
allow if {
	methods[_] == input.method
	input.option == "quick-trip"
	options[input.option][_] == input.user
}
```
- W terminalu, w stworzonym folderze, wywołaj komendę 
```
opa build auth.rego
```
- W  folderze z plikiem docker-compose.yaml wykonaj komendę 
```
docker-compose -f docker-compose.yaml up
```



## Demo deployment steps
Poniżej zostało zaprezentowane przykładowe wykorzystanie przedstawionych wyżej metod konfiguracji i wdrażania aplikacji oraz serwerów OPA.
Na początku zainstaluj niezbędne oprogramowanie wymienione w punkcie 6.
## Configuration set-up

Jeżeli chcesz korzystać z obrazu aplikacji we własnym repozytorium dockerhub zacznij od kroku 7.1. Uwaga, konieczna będzie zmiana nazwy repozytorium w pliku dep3.yaml i plikach rego dopowiadających za polityki. W przeciwnym wypadku kontynuuj configurację. 

Uruchom minikube w terminalu (minikube start).

![auth1.png](images%)
Ekran po instalacji + widock dockera


Podążaj za krokami z punktu 6, stwórz deployment aplikacji.

![auth1.png](images%)
Screen z komendami w terminalu i działającej aplikacji

Następnie wdróż OPA jako admission controller

![auth1.png](images%)
Screen z komendami w terminalu i dockera z deploymentami

Wykonaj punkt 7.6 i skonfiguruj serwer OPA na potrzeby autoryzacji.

![auth1.png](images%)
Screen z komendami w terminalu i docker z deploymentami.
## Data preparation

## Execution procedure

## Results presentation

### Wyniki - autoryzacja

Odmowa dostępu do szybkiej wycieczki dla niezalogowanego użytkownika

![auth1.png](images%2Fauth1.png)

Niezalogowany użytkownik ma dostęp do wycieczkej na podstawie ankietą (ścieżka /region jest pierwszą stroną ankiety

![auth2.png](images%2Fauth2.png)
Użytkownik zalogowany ma dostęp do szybkiej wycieczki
![auth3.png](images%2Fauth3.png)
Użytkownik zalogowany ma dostęp do wycieczki na podstawie ankiety
![auth4.png](images%2Fauth4.png)

## Summary – conclusions

## References
