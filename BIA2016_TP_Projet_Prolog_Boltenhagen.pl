:-dynamic vrai/1.
:-dynamic faux/1.
:-dynamic indefini/1.
:-dynamic marquee/1.
:-dynamic drapeau/1.

/* ------------------ QUESTION 1  ------------------ */ 

/* commentées car de nouvelles sont créés et les remplacent.
regle(r1,[a,b],[c]).
regle(r2,[c,non(d)],[f]).
regle(r3,[f,b],[e]).
regle(r4,[f,a],[non(g)]).
regle(r5,[non(g),f],[b]).
regle(r6,[a,h],[l]).
regle(r7,[e,l],[m]).
*/

/* ------------------ QUESTION 8  ------------------ */ 

regle(r1,[belleVille,tresBonsRestaurants],[villeMeritantVoyage]).
regle(r2,[villeHistorique],[villeMeritantVoyage]).
regle(r3,[autochtonesAccueillants,traditionsFolkloriques],[villeMeritantVoyage]).
regle(r4,[monuments,vegetationAbondante],[belleVille]).
regle(r5,[traditionCulinaire],[bonsRestaurants]).
regle(r6,[restaurants3Etoiles],[tresBonsRestaurants]).
regle(r7,[restaurants3Toques],[tresBonsRestaurants]).
regle(r8,[musees,villeAncienne],[villeHistorique]).
regle(r9,[provence,bordDeMer],[autochtonesAccueillants]).
regle(r10,[parcsVerdoyants,avenuesLarges],[vegetationAbondante]).   

regle(r11,[belleVille,tresBonsRestaurants],[strasbourg]).
regle(r12,[vegetationAbondante,monuments,tresBonsRestaurants],[lyon]).
regle(r13,[villeHistorique],[dole]).
regle(r14,[mauvaisTemps],[brest]).


/* ------------------ QUESTION 2 ------------------ */
/*  ---------  instancie la base des faits ---------*/
faits([]):-!.
faits([non(A)|L]):-not(faux(A)),assert(faux(A)),faits(L),!.
faits([A|L]):-not(vrai(A)),assert(vrai(A)),faits(L).


/* ------------------ QUESTION 3 ------------------ */
/*  ---------  vide la base de faits ------------  */
raz():-retractall(vrai(_)),retractall(faux(_)),retractall(drapeau(changement)),retractall(marquee(_)),retractall(indefini(_)).


/* ------------------ QUESTION 4 ------------------ */
/* -- vérifie si A est  dans la base des faits --- */
valide([]).
valide([non(A)|L]):-faux(A),valide(L),!.
valide([A|L]):-vrai(A),valide(L).


/* ----- ajoute dans la base des faits  ---------*/
conclue([]):-!.
conclue([non(A)|L]):-faux(A),conclue(L),!.
conclue([non(A)|L]):-faits([non(A)]),conclue(L),!.
conclue([A|L]):-vrai(A),conclue(L),!.
conclue([A|L]):-faits([A]),conclue(L).

/* ---------- affiche a ou non(a) ---------- */
affichage(A):-vrai(A),write(A),write(" "),fail.
affichage(A):-faux(A),write("non("),write(A),write(") "),fail.

/* ------saturer, pose le drapeau ---------*/
/*-- drapeau(changement) <=> changement:faux 
  -- dans l'algorithme donné --------------*/
saturer:-assert(drapeau(changement)),saturer2.
saturer2:-regle(R,L1,L2),           /*soit R */
         not(marquee(R)),           /* si pas marquee */ 
         valide(L1),                /* si valide prémisses */
         write(R),
         conclue(L2),               /* ajoute L2 à faits */
         assert(marquee(R)),        /* note R marquee */ 
         retractall(drapeau(changement)),    /* note changement à vrai (en supprimant drapeau)*/
         write(":"),
         not(affichage(_)),
         write("\n"),
         fail.
saturer2:-not(drapeau(changement)), assert(drapeau(changement)),saturer2.
saturer2:-drapeau(changement),!. /*changement faux -> stop tant que*/



/* ------------------ QUESTION 5 ------------------ */

satisfait([]).
satisfait([A|L]):-!,satisfait(A),satisfait(L).
satisfait(E):-valide([E]),write(E),write(" dans la base de faits \n").
satisfait(E):-
        not(valide([E])),
        regle(R,L1,L2),
        member(E,L2),
        satisfait(L1),
        write(E),
        write( " satisfait grace a "),
        write(R),
        write("\n").


/* ------------------ QUESTION 6 ------------------ */
/* --------- true si F figure à droite dans R ----- */
figure_droite(R,F):-regle(R,_,L2),member(F,L2).

/* --------- true si F figure à gauche dans R ----- */
figure_gauche(R,F):-regle(R,L1,_),member(F,L1).

/* ----------- fonction auxilliaire -------------- */
auxobservable(C):- figure_gauche(_,C).

observable(C):-auxobservable(C),not(figure_droite(_,C)).
terminal(P):-figure_droite(_,P) , not(auxobservable(P)).


/* ------------------ QUESTION 7 ------------------ */
valide2([]).
valide2([non(A)|L]):-faux(A),valide(L),!.
valide2([A|L]):-vrai(A),valide(L).
valide2([A|L]):-indefini(A),valide(L).
/* ----- uniquement E valide dans L --------------- */
seul_valide([],_).
seul_valide([F|L],E):-F\=E,valide2([F]),seul_valide(L,E).
seul_valide([F|L],E):-E==F,seul_valide(L,E).

/* ----- si on a qu'un premisse inconnu ---------- */
presque_declanchable(R,E):-regle(R,L1,_),member(E,L1),not(valide2([E])),seul_valide(L1,E).

/* --- etudie la reponse de l'utilisateur ---- */
etudie_reponse(o,non(E)):-assert(faux(E)),satisfait(E).
etudie_reponse(n,non(E)):-assert(vrai(E)),satisfait(E).
etudie_reponse(o,E):-assert(vrai(E)),satisfait(E).
etudie_reponse(n,E):-assert(faux(E)),satisfait(E).
etudie_reponse(i,E):-assert(indefini(E)).

/* --- cherche des premisses à demander ----*/
demander():-
    presque_declanchable(_,E),
    write("j essaie de prouver "),write(E),
    write("\n \n"),
    write("Est ce que "),write(E),write("? (o-n-i)\n"),
    read(REP),
    etudie_reponse(REP,E),
    go.
demander():-true.

/* ------------ chainage mixte ------------- */
go:-assert(drapeau(changement)),saturer2,demander.

/* ------------ question 9 ------------ */
/*
faits([parcsVerdoyants,avenuesLarges,monuments,restaurants3Toques,villeAncienne]).
saturer.
------------ résultat ----------------
r7:parcsVerdoyants avenuesLarges monuments restaurants3Toques villeAncienne tresBonsRestaurants 
r10:parcsVerdoyants avenuesLarges monuments restaurants3Toques villeAncienne tresBonsRestaurants vegetationAbondante 
r4:parcsVerdoyants avenuesLarges monuments restaurants3Toques villeAncienne tresBonsRestaurants vegetationAbondante belleVille 
r1:parcsVerdoyants avenuesLarges monuments restaurants3Toques villeAncienne tresBonsRestaurants vegetationAbondante belleVille villeMeritantVoyage 
*/


/* ------------ question 10 ------------ */
/*
raz.
faits([parcsVerdoyants,avenuesLarges,monuments,restaurants3Toques,villeAncienne]).
satisfait(villeMeritantVoyage).
------------ résultat ----------------
monuments dans la base de faits 
parcsVerdoyants dans la base de faits 
avenuesLarges dans la base de faits 
vegetationAbondante satisfait grace a r10
belleVille satisfait grace a r4
restaurants3Toques dans la base de faits 
tresBonsRestaurants satisfait grace a r7
villeMeritantVoyage satisfait grace a r1
*/


/* ------------ question 11 ------------ */
ville(lyon).
ville(brest).
ville(strasbourg).
ville(dole).

grandesVillesFrancaises(X):-ville(X),vrai(X).

/* 
grandesVillesFrancaises(X).
X=Lyon;
X=strasbourg;
*/
