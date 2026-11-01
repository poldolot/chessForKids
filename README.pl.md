# Szachy dla dzieci

Darmowa, działająca offline aplikacja ucząca szachów dzieci od 5 lat, które jeszcze
nie czytają. Wszystko prowadzą obrazki i głos: do poruszania się po aplikacji nigdy
nie trzeba czytać.

English version: [README.md](README.md)

## Co będzie umiała

- **Nauka** – lekcja o każdej figurze (pion, wieża, goniec, hetman, król, skoczek),
  potem zasady: ustawienie, szach, mat, pat, roszada, bicie w przelocie, promocja.
- **Mini‑gry** – Wojna pionów, Drogi wieży, Tory gońca, Wyścig królem, Polowanie.
- **Partia** – pełna gra z celowo łagodnym komputerem.
- Gwiazdki, paski postępu i odznaki; kilka profili dzieci na jednym urządzeniu.
- W pełni offline. Bez kont, analityki, reklam i uprawnienia do internetu.

## Technologia

Flutter (najpierw Android, gotowe pod iOS) z własnym silnikiem szachowym w Darcie,
żeby lekcje mogły używać plansz bez królów. Głos z systemowego syntezatora mowy,
nagrania lektora w planach. Polski i angielski od startu.

## Stan prac

Wszystkie trzy działy v1 są gotowe: Nauka (14 lekcji), Mini‑gry (pięć gier po pięć poziomów; każda plansza jest losowana na nowo i sprawdzana, czy da się ją rozwiązać) i Partia
z prostym komputerem (pełne reguły FIDE, podpowiedzi, cofanie, poddanie, zapis
i wznowienie partii, gwiazdki i odznaki), z głosem po polsku i angielsku, na bazie
szkieletu aplikacji (profile, menu, strefa rodzica) i przetestowanego silnika reguł.
Dalej: wykończenie, dźwięki i wydanie.

## Licencja

MIT, patrz [LICENSE](LICENSE).
