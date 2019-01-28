unit omLexer;

interface

uses
    omToken
  , System.Generics.Collections
  , System.StrUtils
  , SysUtils;

type
  TomLexer = class

  private
    Source : String;
    SourcePos : Integer;

    function PeekChar(var Char_: Char) : Boolean;
    function GetChar(var Char_: Char) : Boolean;

    function ReadToken(var Token: TomToken) : Boolean;
    function ReadNumber: TomToken;
    function ReadOperator: TomToken;
    function ReadIdentifier: TomToken;

  public
    function Lex : TObjectList<TomToken>;
    constructor Create(Source: String);
  end;

implementation

  function TomLexer.PeekChar(var Char_: Char) : Boolean;
  begin
    if SourcePos <= Length(Source) then begin
      Result := True;
      Char_ := Source[SourcePos];
    end
    else begin
      Result := False;
      Char_ := ' ';
    end;
  end;

  // _______________________________________________________________________________________________

  function TomLexer.GetChar(var Char_: Char) : Boolean;
  begin
    Result := False;

    if PeekChar(Char_) then begin
      SourcePos := SourcePos + 1;
      Result := True;
    end;
  end;

  // _______________________________________________________________________________________________

  function TomLexer.ReadToken(var Token: TomToken) : Boolean;
  var
    Char_: Char;

  begin
    Result := True;

    //Trim out the whitespace before the token
    while PeekChar(Char_) do begin
      if ContainsText(' ', String(Char_)) then begin
        SourcePos := SourcePos + 1;
      end
      else begin
        break
      end;
    end;

    if PeekChar(Char_) then begin
       if ContainsText('0123456789', String(Char_)) then begin
         Token := ReadNumber;
       end
       else if ContainsText('(,)+-*/%^', String(Char_)) then begin
         Token := ReadOperator;
       end
       else if ContainsText('abcdefghijklmnopqrstuvwxyz', String(Char_)) then begin
         Token := ReadIdentifier;
       end
       else begin
         raise Exception.Create('Unrecognized character!');
       end;
    end
    else begin
      Result := False;
    end;
  end;

  // _______________________________________________________________________________________________

  function TomLexer.ReadNumber: TomToken;
  var
    Char_: Char;
    Value: String;
  begin
    while PeekChar(Char_) do begin
      if ContainsText('0123456789.', String(Char_)) then begin
        GetChar(Char_);
        Value := Value + String(Char_);
      end
      else begin
        break;
      end;
    end;

    Result := TomToken.Create(Number, Value); // Managed
  end;

  // _______________________________________________________________________________________________

  function TomLexer.ReadOperator: TomToken;
  var
    Char_: Char;
  begin
    GetChar(Char_);
    case Char_ of
      '(': Result := TomToken.Create(OpLeftParen,  String(Char_));  // Managed
      ')': Result := TomToken.Create(OpRightParen, String(Char_));  // Managed
      ',': Result := TomToken.Create(OpComma,      String(Char_));  // Managed
      '+': Result := TomToken.Create(OpPlus,       String(Char_));  // Managed
      '-': Result := TomToken.Create(OpMinus,      String(Char_));  // Managed
      '*': Result := TomToken.Create(OpMultiply,   String(Char_));  // Managed
      '/': Result := TomToken.Create(OpDivide,     String(Char_));  // Managed
      '%': Result := TomToken.Create(OpModulo,     String(Char_));  // Managed
      '^': Result := TomToken.Create(OpExponent,   String(Char_));  // Managed
      else begin
        Result := nil;
      end;
    end;
  end;

  // _______________________________________________________________________________________________

  function TomLexer.ReadIdentifier: TomToken;
  var
    Char_: Char;
    Value: String;
  begin
    while PeekChar(Char_) do begin
      if ContainsText('abcdefghijklmnopqrstuvwxyz', String(Char_)) then begin
        GetChar(Char_);
        Value := Value + String(Char_);
      end
      else begin
        break;
      end;
    end;

    if AnsiCompareText('pi', Value) = 0 then begin
      Result := TomToken.Create(Number, FloatToStr(Pi)); // Managed
    end
    else if AnsiCompareText('e', Value) = 0 then begin
      Result := TomToken.Create(Number, FloatToStr(Exp(1.0))); // Managed
    end
    else if AnsiCompareText('mod', Value) = 0 then begin
      Result := TomToken.Create(OpModulo, Value); // Managed
    end
    else begin
      Result := TomToken.Create(Identifier, Value); // Managed
    end;
  end;

  // _______________________________________________________________________________________________

  function TomLexer.Lex : TObjectList<TomToken>;
  var
    Token : TomToken;
  begin
    Result := TObjectList<TomToken>.Create(true); // Unmanaged

    while ReadToken(Token) do begin
      Result.Add(Token);
    end;
  end;

  // _______________________________________________________________________________________________

  constructor TomLexer.Create(Source: String);
  begin
    Self.Source := Source;
    Self.SourcePos := Low(Source);
  end;
end.
