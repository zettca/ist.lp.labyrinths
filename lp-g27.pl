% Projecto LP 2015/2016 - Labirintos | Grupo 27
% 77897 Francisco Ferreira
% 78013 Bruno Henriques

% posCoords/3: Coordenadas, Direcao, Tuplo
% Unifica se Tuplo corresponde a um tuplo (Direcao, Coordenadas)
posCoords((L,C), c, (c,Ls,C)) :- Ls is L-1.
posCoords((L,C), b, (b,Ls,C)) :- Ls is L+1.
posCoords((L,C), e, (e,L,Cs)) :- Cs is C-1.
posCoords((L,C), d, (d,L,Cs)) :- Cs is C+1.

% posVisited/2: Lista de Tuplos, Coordenada
% Unifica se Coordenada se encontra na Lista de Tuplos
posVisited([(_,L,C)|_], (_,L,C)) :- !.
posVisited([_|T], Pos) :- posVisited(T, Pos).

% posSorted/3: Lista de Tuplos, Posicao Inicial, Posicao Final
% Unifica se Lista de Tuplos esta ordenada por distancia
posSorted([_], _, _).
posSorted([(_,L1,C1),(_,L2,C2)|T], Pi, Pf) :- 
	distancia(Pf, (L1,C1), Df1), distancia(Pf, (L2,C2), Df2),
	distancia(Pi, (L1,C1), Di1), distancia(Pi, (L2,C2), Di2),
	(Df1<Df2 ; (Df1==Df2 , Di1>=Di2)), posSorted([(_,L2,C2)|T], Pi, Pf).

% movs_possiveis/4: Labirinto, Coordenadas, Movimentos Efetuados, Movimentos Possiveis
% Unifica se Poss corresponde aos movimentos possiveis dado uma cordenada do Labirinto
movs_possiveis(Lab, (L,C), Movs, Poss) :-
	nth1(L, Lab, Line), nth1(C, Line, WallDirs),
	subtract([c,b,e,d], WallDirs, PossDirs),		% devolve direcoes sem paredes
	maplist(posCoords((L,C)), PossDirs, PossCords),	% mapeia Dirs > Tuplos
	exclude(posVisited(Movs), PossCords, Poss).		% exclui as posicoes ja visitadas

% distancia/3: Coordenada 1,  Coordenada 2, Distancia
% Unifica se Dist corresponde a distancia entre as duas coordenadas
distancia((L1,C1), (L2,C2), Dist) :-
	abs(L2-L1, Dl), abs(C2-C1, Dc), Dist is Dl+Dc.

% ordena_poss/4: Movimentos, Movimentos ordenados, Posicao inicial, Posicao final
% Unifica se Poss_ord corresponde a ordenacao Poss por distancia seguindo o criterio:
% Criterio: Menor distancia a Pf > Maior distancia a Pi > direcoes [c,b,e,d]
ordena_poss(Poss, Poss_ord, Pi, Pf) :-
	permutation(Poss, Poss_ord), posSorted(Poss_ord, Pi, Pf), !.

% resolve/4: Labirinto, Posicao Inicial, Posicao Final, Movimentos
% Unifica se Movs e a lista de movimentos a efetuar para resolver o labirinto Lab
% resolve1/4 segue um caminho estatico | resolve2/4 segue o caminho mais curto
resolve1(Lab, (L,C), Pos_final, Movs) :-	% caminho estatico (c>b>e>d)
	resolve1Aux(Lab, (L,C), Pos_final, [(i,L,C)], Movs), !.
resolve2(Lab, (L,C), Pos_final, Movs) :-	% caminho mais curto (greedy)
	resolve2Aux(Lab, (L,C), (L,C), Pos_final, [(i,L,C)], Movs), !.

% resolve auxiliares para recursao com processo iterativo

resolve1Aux(_, Pos_final, Pos_final, Movs, Movs).
resolve1Aux(Lab, Pos_atual, Pos_final, MovsDone, Movs) :-
	movs_possiveis(Lab, Pos_atual, MovsDone, MovsPoss),
	member((D,L,C), MovsPoss),		% escolhe direcao a seguir 
	append(MovsDone, [(D,L,C)], MovsDone1),
	resolve1Aux(Lab, (L,C), Pos_final, MovsDone1, Movs).

resolve2Aux(_, _, Pos_final, Pos_final, Movs, Movs).
resolve2Aux(Lab, Pos_inicial, Pos_atual, Pos_final, MovsDone, Movs) :-
	movs_possiveis(Lab, Pos_atual, MovsDone, MovsPoss),
	ordena_poss(MovsPoss, MovsPossOrd, Pos_inicial, Pos_final),
	member((D,L,C), MovsPossOrd),	% escolhe direcao ordenada a seguir 
	append(MovsDone, [(D,L,C)], MovsDone1),
	resolve2Aux(Lab, Pos_inicial, (L,C), Pos_final, MovsDone1, Movs).