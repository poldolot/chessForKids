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

Gotowy szkielet aplikacji: profile, menu główne, strefa rodzica, głos, polski i angielski
oraz interaktywna szachownica. Silnik reguł szachowych jest kompletny i przetestowany.
Dalej: lekcje, mini‑gry i komputerowy przeciwnik.

## Licencja

MIT, patrz [LICENSE](LICENSE).
