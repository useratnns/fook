import 'dart:math';

class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});
}

final List<Quote> historicalQuotes = [
  Quote(text: "The impediment to action advances action. What stands in the way becomes the way.", author: "Marcus Aurelius"),
  Quote(text: "He who has a why to live can bear almost any how.", author: "Friedrich Nietzsche"),
  Quote(text: "Victorious warriors win first and then go to war, while defeated warriors go to war first and then seek to win.", author: "Sun Tzu"),
  Quote(text: "An unexamined life is not worth living.", author: "Socrates"),
  Quote(text: "I am not afraid of an army of lions led by a sheep; I am afraid of an army of sheep led by a lion.", author: "Alexander the Great"),
  Quote(text: "It is not the man who has too little, but the man who craves more, that is poor.", author: "Seneca"),
  Quote(text: "Education is the most powerful weapon which you can use to change the world.", author: "Nelson Mandela"),
  Quote(text: "Imagination is more important than knowledge.", author: "Albert Einstein"),
  Quote(text: "The only limit to our realization of tomorrow will be our doubts of today.", author: "Franklin D. Roosevelt"),
  Quote(text: "Do not pray for an easy life, pray for the strength to endure a difficult one.", author: "Bruce Lee"),
  Quote(text: "I have no special talent. I am only passionately curious.", author: "Albert Einstein"),
  Quote(text: "Knowing others is intelligence; knowing yourself is true wisdom.", author: "Lao Tzu"),
];

Quote getRandomQuote() {
  final random = Random();
  return historicalQuotes[random.nextInt(historicalQuotes.length)];
}
