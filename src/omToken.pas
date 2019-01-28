unit omToken;

interface
  type
    TokenType = (
      Invalid,
      Number,
      Identifier,
      OpLeftParen,
      OpRightParen,
      OpPlus,
      OpMinus,
      OpMultiply,
      OpDivide,
      OpModulo,
      OpExponent,
      OpComma
    );

  type
    TomToken = class

      Type_ : TokenType;
      Data : String;

      constructor Create(Type_ : TokenType; Data: String);

    end;

implementation
  constructor TomToken.Create(Type_ : TokenType; Data: String);
  begin
    Self.Type_ := Type_;
    Self.Data := Data;
  end;

end.
