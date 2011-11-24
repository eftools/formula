package inobr.eft.formula.parser 
{
	/**
	 * ...
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class Parser 
	{
		// create and remember the only one exemplar of SelectionManager class
		private static var _instance:Parser = new Parser();
		// list of states
		private const sBegin:String = "sBegin";
		private const sDigit:String = "sDigit";
		private const sOperator:String = "sOperator";
		private const sDivider:String = "sDivider";
		private const sBeginWithZero:String = "sBeginWithZero";
		
		// list of operators
		private var operators:Array = ["+", "–", "·"];
		private var dividers:Array = ["."];
		
		public function Parser():void
		{
			if (_instance != null)
				throw new Error("An instance of Parser is already exists! You can not create another instance of Parser class.");
		}
		
		/**
		 * Parser receives a Math string (for example: "1+1")
		 * makes its lexical parsing and calculating. Returns an
		 * array with the result (with only one Number or with a list 
		 * of tokens if the result can't be received).
		 * 
		 * @param	listOfTokens
		 * @return  result 
		 */
		public function parse(mathString:String):String
		{	
			// convert "1+1+2" to ["1", "+", "1", "+", "2"]
			var listOfTokens:Array = lexicalParse(mathString);
			
			// convert from infix to revers polish form
			var reversePolish:Array = [];
			reversePolish = convertInfixToRPF(listOfTokens);
			
			// calculate
			return calculateRPF(reversePolish);
		}
		
		/**
		 * Converts a Math string (for example: "1+1") to the list of
		 * tokens like this ["1", "+", "1"]
		 * 
		 * @param	mathString
		 * @return
		 */
		public function lexicalParse(mathString:String):Array
		{
			var listOfTokens:Array/* of Strings */ = [];
			
			var state:String = sBegin;
			var i:int = 0;
			var s:String = "";
			var currentToken:String = "";
			while (s = mathString.charAt(i)) 
			{
				switch (state) 
				{
					case sBegin:
						if (!isNaN(Number(s)))
						{
							if (Number(s) == 0)
							{
								currentToken += s;
								state = sBeginWithZero;
							}
							else
							{
								currentToken += s;
								state = sDigit;
							}
						}
						else
						{
							if (operators.indexOf(s) >= 0)
							{
								currentToken = s;
								state = sOperator;
							}
							else
								return formError(listOfTokens, "StartsWithDivisorError");
						}
					break;
					
					case sBeginWithZero:
						if (dividers.indexOf(s) >= 0)
						{
							currentToken += s;
							state = sDigit;
						}
						else
						{
							if (operators.indexOf(s) >= 0)
							{
								listOfTokens.push(currentToken);
								currentToken = s;
								state = sOperator;
							}
							else
								return formError(listOfTokens, "StartsWithZeroError");
						}
					break;
					
					case sDigit:
						if (!isNaN(Number(s)))
						{
							currentToken += s;
							state = sDigit;
						}
						else
						{
							if (dividers.indexOf(s) >= 0)
							{
								// the divider must be only ONE in a token
								var tmp:int = currentToken.indexOf(s);
								if (currentToken.indexOf(s) == -1)
								{
									currentToken += s;
									state = sDivider;
								}
								else
									return formError(listOfTokens, "TwoDivisorsInNumberError");
							}
							else
							{
								if (operators.indexOf(s) >= 0)
								{
									listOfTokens.push(currentToken);
									currentToken = s;
									state = sOperator;
								}
								else
									return formError(listOfTokens, "LetterInNumberError");
							}
						}
					break;
					
					case sDivider:
						if (!isNaN(Number(s)))
						{
							currentToken += s;
							state = sDigit;
						}
						else
							return formError(listOfTokens, "NotDigitAfterDividerError");
					break;
					
					case sOperator:
						listOfTokens.push(currentToken);
						if (!isNaN(Number(s)))
						{
							if (Number(s) == 0)
							{
								currentToken = s;
								state = sBeginWithZero;
							}
							else
							{
								currentToken = s;
								state = sDigit;
							}
						}
						else
							return formError(listOfTokens, "TwoOperatorsError");
					break;
					
					default:
					break;
				}
				
				i++;
			}
			
			listOfTokens.push(currentToken);
			
			return listOfTokens;
		}
		
		private function formError(listOfTokens:Array, type:String):Array
		{
			listOfTokens.splice(0, listOfTokens.length);
			listOfTokens.push("error");
			listOfTokens.push(type);
			return listOfTokens;
		}
		
		/**
		 * Convert formulas written in infix notation ("1+1")
		 * to Reverse Polish Notation ("11+"). Receives a list of tokens
		 * (for example: ["1", "+", "1"])
		 * 
		 * @param	infixNotation
		 * @return
		 */
		public function convertInfixToRPF(infixNotation:Array):Array
		{
			var reversePolish:Array = [];
			var stack:Array = [];
			
			// if "–" comes first we put "0" before it	
			if (infixNotation[0] == "–")
				infixNotation.unshift("0");
			
			for (var i:int = 0; i < infixNotation.length; i++) 
			{
				var currentToken:String = infixNotation[i];
				
				if (!isNaN(Number(currentToken)))
				{
					reversePolish.push(currentToken);
				}
				else
				{
					switch (currentToken) 
					{
						case "+":
							if (stack.length > 0)
								{
									reversePolish.push(stack[stack.length - 1]);
									stack.pop();
								}
							
							stack.push(currentToken);
						break;
						
						case "–":
							if (stack.length > 0)
								{
									reversePolish.push(stack[stack.length - 1]);
									stack.pop();
								}
							
							stack.push(currentToken);
						break;
						
						case "·":
							stack.push(currentToken);
						break;
						
						default:
						break;
					}
				}
			}
			
			// popup operators to the output stream (in reverse order)
			for (i = stack.length - 1; i >-1; i--) 
			{
				reversePolish.push(stack[i]);
			}
			
			return reversePolish;
		}
		
		/**
		 * Try to calculate formulas written in Reverse Polish Notation.
		 * Receive a list of tokens in RPN (for example: ["1", "1", "+"])
		 * 
		 * @param	reversePolish
		 * @return
		 */
		public function calculateRPF(reversePolish:Array):String
		{
			// if comes only one token we return it
			if (reversePolish.length == 1)
				return reversePolish[0];
				
			var stack:Array = [];
			var res:Number;
			var m:int = 0;
			
			for (var i:int = 0; i < reversePolish.length; i++)
			{
				var currentToken:String = reversePolish[i];
				if (!isNaN(Number(currentToken)))
				{
					stack[m] = Number(currentToken);
					m++;
					continue;
				}
				
				switch (currentToken)
				{
					case "+":
					{
						res = stack[m - 2] + stack[m - 1];
						break;
					} 
					case "–":
					{
						res = stack[m - 2] - stack[m - 1];
						break;
					}
					case "·":
					{
						res = stack[m - 2] * stack[m - 1];
						break;
					}
				}
				stack[m - 2] = res;
				m--;
			}
			
			return res.toString();
		}
		
		public static function get instance():Parser
		{
			return _instance;
		}
		
	}

}