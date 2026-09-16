# Grenen `appcast`

Her ligger ÉN fil: `appcast.xml`. Det er Sparkle-feedet til husets eget byg af
boringNotch med Jarvis-fanen. Appen henter den på

    https://raw.githubusercontent.com/lubbe05/jarvis-notch/appcast/appcast.xml

Filen skrives af husets `notch_appcast.py udgiv` efter hvert grønt byg og er
signeret med husets private Ed25519-nøgle, som kun findes på husets maskine.
Ret den aldrig i hånden — så passer signaturen ikke længere, og appen afviser
opdateringen (med rette).

Grenen har ingen kode med vilje: den er en ren fil-gren, så `raw.githubusercontent.com`
kan servere den uden at rode med selve projektet.
