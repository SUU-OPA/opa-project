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


## Environment configuration description
Wersja demonstracyjna działania systemu OPA wykorzystywać będzie system Windows 10 wraz z WSL 2 (Windows Subsystem for Linux) oraz Docker Desktop, który umożliwi lokalne uruchomienie oraz zarządzanie kontenerami w środowisku Kubernetes na potrzeby uruchomienia aplikacji, oraz zintegrowanie jej z systemem OPA.

## Installation method

## How to reproduce - step by step

## Infrastructure as Code approach

## Demo deployment steps

## Configuration set-up

## Data preparation

## Execution procedure

## Results presentation

## Summary – conclusions

## References
