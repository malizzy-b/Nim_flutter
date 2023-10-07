import 'package:flutter/material.dart';
import 'dart:math';

enum GameState { NotStarted, InProgress, Ended }

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: const Color(0xFF242423),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple, // Cor da AppBar
        ),
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<bool> bolinhas = []; // Lista de bolinhas
  bool jogadorJoga = true;
  bool gameOver = false;
  String winner = '';
  int bolinhasRetiradas = 0;
  int bolinhasRestantes = 0;
  int maxRetirar = 0; // Número máximo a ser retirado
  GameState gameState = GameState.NotStarted;

  @override
  void initState() {
    super.initState();
  }

  void _iniciarJogo() async {
    // Solicitar ao usuário o número de bolinhas iniciais
    int numeroBolinhas = await _solicitarNumeroBolinhas();

    if (numeroBolinhas > 21) {
      numeroBolinhas = 21;
    }

    setState(() {
      bolinhas = List.generate(numeroBolinhas, (index) => true);
      bolinhasRestantes = numeroBolinhas;
      maxRetirar = 2; // Máximo de 2 bolinhas para retirar por vez
      gameState = GameState.InProgress;
    });
  }

  Future<int> _solicitarNumeroBolinhas() async {
    int? numeroBolinhas;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Número de Bolinhas'),
          content: Text('Informe o número de bolinhas iniciais (máximo 21):'),
          actions: <Widget>[
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                numeroBolinhas = int.tryParse(value);
              },
            ),
            TextButton(
              child: Text('Confirmar'),
              onPressed: () {
                if (numeroBolinhas != null && numeroBolinhas! >= 2) {
                  Navigator.of(context).pop(numeroBolinhas);
                }
              },
            ),
          ],
        );
      },
    );

    return numeroBolinhas ?? 2;
  }

  void jogar(int quantidade) {
    if (!gameOver && quantidade > 0 && quantidade <= maxRetirar) {
      setState(() {
        bolinhasRetiradas += quantidade;
        bolinhasRestantes -= quantidade;
        for (int i = 0; i < quantidade; i++) {
          bolinhas.removeLast();
        }
        jogadorJoga = !jogadorJoga;

        if (bolinhasRestantes == 0) {
          gameOver = true;
          winner = jogadorJoga ? 'Você ganhou!' : 'Computador ganhou!';
          gameState = GameState.Ended;
        } else if (!jogadorJoga) {
          // É a vez do computador
          Future.delayed(const Duration(seconds: 1), () {
            computadorJoga();
          });
        }
      });
    }
  }

  void computadorJoga() {
    if (!gameOver) {
      Random random = Random();
      int quantidade = random.nextInt(maxRetirar) + 1;
      jogar(quantidade);
    }
  }

  void reiniciarJogo() {
    setState(() {
      jogadorJoga = true;
      gameOver = false;
      winner = '';
      bolinhasRetiradas = 0;
      gameState = GameState.NotStarted;
    });
  }

  String get buttonText {
    switch (gameState) {
      case GameState.NotStarted:
        return 'Iniciar Jogo';
      case GameState.InProgress:
        return 'Reiniciar Jogo';
      case GameState.Ended:
        return 'Jogar Novamente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nim', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            const Text('Marina Lima Nogueira  RA: 1431432312009',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple)),
            const SizedBox(height: 18),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        gameOver
                            ? 'Fim do Jogo!'
                            : jogadorJoga
                                ? 'Sua vez!'
                                : 'Vez do Computador',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple)),
                    const SizedBox(height: 25),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: bolinhas
                            .map((bolinha) => Bolinha(
                                  visivel: bolinha,
                                  onTap: () {
                                    if (jogadorJoga) {
                                      jogar(1);
                                    }
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (gameState == GameState.NotStarted ||
                              gameState == GameState.Ended) {
                            _iniciarJogo();
                          } else if (gameState == GameState.InProgress) {
                            reiniciarJogo();
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.deepPurple, // Cor do botão
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold, // Texto em negrito
                        ),
                      ),
                      child: Text(buttonText),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      gameOver
                          ? winner
                          : 'Bolinhas Retiradas: $bolinhasRetiradas\nBolinhas Restantes: $bolinhasRestantes',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Você tem $bolinhasRestantes bolinhas e pode retirar até $maxRetirar por vez.',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Bolinha extends StatelessWidget {
  final bool visivel;
  final VoidCallback onTap;

  const Bolinha({required this.visivel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: visivel ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: visivel ? Colors.white : Colors.transparent,
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
