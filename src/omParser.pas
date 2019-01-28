unit omParser;

interface

  uses
      omToken
    , omExpressions
    , System.Generics.Collections, SysUtils;

  type
    TomParser = class

  private
    TokenPos: Integer;
    Tokens: TObjectList<TomToken>;

    function PeekToken(var Token: TomToken) : Boolean;
    function GetToken(var Token: TomToken) : Boolean;

    // Recursive-descent expression parsing
    function ParseAddition: TomExpression;
    function ParseMultiplication: TomExpression;
    function ParseUnary: TomExpression;
    function ParsePrimary: TomExpression;
    function ParseFunction: TomExpression;
    function ParseArgumentList: TObjectList<TomExpression>;

  public
    function Parse(Subparsing: Boolean = False): TomExpression;
    constructor Create(Tokens: TObjectList<TomToken>);
  end;

  // _______________________________________________________________________________________________
  // Stores meta-data for validating a single function
  type
    TomFunctionData = record

    Name : String;
    Args : Integer;

    function IsEmpty: Boolean;
    class function RetrieveByName(Identifier: String): TomFunctionData; static;
  end;

  //Records of validation data for functions
  const
    C_FunctionValidators : array[1..8] of TomFunctionData =
    (
      (Name: 'min';       Args: 2),
      (Name: 'max';       Args: 2),
      (Name: 'rand';      Args: 2),
      (Name: 'abs';       Args: 1),
      (Name: 'sqrt';      Args: 1),
      (Name: 'round';     Args: 1),
      (Name: 'remainder'; Args: 1),
      (Name: 'invalid')
    );

implementation

  function TomParser.GetToken(var Token: TomToken) : Boolean;
  begin
    if PeekToken(Token) then begin
      Result := True;
      TokenPos := TokenPos + 1;
    end
    else begin
      Result := False;
    end;
  end;

  // _______________________________________________________________________________________________

  function TomParser.PeekToken(var Token: TomToken) : Boolean;
  begin
    if TokenPos < Tokens.Count then begin
      Result := True;
      Token := Tokens[TokenPos];
    end
    else begin
      Result := False;
    end;
  end;

  // _______________________________________________________________________________________________

  function TomParser.ParseAddition;
  var
    Token: TomToken;
    ExprOp: OpType;

  begin
    Result := ParseMultiplication;

    while PeekToken(Token) do begin
      if Token.Type_ in [OpPlus, OpMinus] then begin

        case Token.Type_ of
          OpPlus:   ExprOp := Plus;
          OpMinus:  ExprOp := Minus;
          else begin
            ExprOp := Plus;
          end;
        end;

        GetToken(Token);
        Result := TomExpressionBinary.Create(Result, ExprOp, ParseMultiplication); // Unmanaged
      end
      else begin
        break;
      end;
    end;

    if Result = nil then begin
      raise Exception.Create('Invalid expression.');
    end;
  end;

  // _______________________________________________________________________________________________

  function TomParser.ParseMultiplication;
  var
    Token: TomToken;
    ExprOp: OpType;

  begin
    Result := ParseUnary;

    while PeekToken(Token) do begin
      if Token.Type_ in [OpMultiply, OpDivide, OpModulo] then begin
        case Token.Type_ of
          OpMultiply: ExprOp := Multiply;
          OpDivide:   ExprOp := Divide;
          OpModulo:   ExprOp := Modulo;
          else begin
            ExprOp := Multiply;
          end;
        end;

        GetToken(Token);
        Result := TomExpressionBinary.Create(Result, ExprOp, ParseUnary); // Unmanaged
      end
      else begin
        break;
      end;
    end;

    if Result = nil then begin
      raise Exception.Create('Invalid expression.');
    end;
  end;

  // _______________________________________________________________________________________________

  function TomParser.ParseUnary;
  var
    Token: TomToken;
    ExprOp: OpType;

  begin
    Result := nil;

    if PeekToken(Token) then begin
      if Token.Type_ = OpMinus then begin

        case Token.Type_ of
          OpMinus: ExprOp := Negate;
          else begin
            ExprOp := Negate;
          end;
        end;

        GetToken(Token);
        Result := TomExpressionUnary.Create(ExprOp, ParseUnary); // Unmanaged

      end
      else begin
        Result := ParsePrimary;
      end;
    end;

    if Result = nil then begin
      raise Exception.Create('Invalid expression.');
    end;
  end;

  // _______________________________________________________________________________________________

  function TomParser.ParsePrimary;
  var
    Token: TomToken;
  begin
    Result := nil;
    PeekToken(Token);

    if Token.Type_ = Number then begin
      GetToken(Token);
      Result := TomExpressionLiteral.Create(StrToFloat(Token.Data));
    end
    else if Token.Type_ = Identifier then begin
      Result := ParseFunction;
    end
    else if Token.Type_ = OpLeftParen then begin
      GetToken(Token); // Left paren
      Result := Parse(True);
      GetToken(Token); // Right paren

      if Token.Type_ <> OpRightParen then begin
        raise Exception.Create('Invalid expression.');
      end;
    end;

    if Result = nil then begin
     raise Exception.Create('Invalid expression.');
    end
    else begin
      PeekToken(Token);

      if Token.Type_ = OpExponent then begin
        GetToken(Token);
        Result := TomExpressionBinary.Create(Result, Exponent, ParseUnary); //Unmanaged
      end;
    end;
  end;

  // _______________________________________________________________________________________________

  function TomParser.ParseFunction;
  var
    Token: TomToken;
    FunctionValidator: TomFunctionData;
    ArgumentList: TObjectList<TomExpression>;
  begin
    GetToken(Token);
    FunctionValidator := TomFunctionData.RetrieveByName(Token.Data);

    if not FunctionValidator.IsEmpty then begin

      ArgumentList := ParseArgumentList;

      if (ArgumentList.Count <> FunctionValidator.Args) then begin
        raise Exception.Create(Token.Data
                              + ' requires '
                              + IntToStr(FunctionValidator.Args)
                              + ' argument(s)');
      end;

      Result := TomExpressionFunction.Create(Token.Data, ArgumentList);
    end
    else begin
      raise Exception.Create('Invalid expression.');
    end;
  end;

  // _______________________________________________________________________________________________

  function TomParser.ParseArgumentList;
  var
    Token: TomToken;
  begin
    Result := TObjectList<TomExpression>.Create;

    try
      GetToken(Token);
      if Token.Type_ <> OpLeftParen then begin
        raise Exception.Create('Expected "(" before function arguments.');
      end;

      while True do begin
        Result.Add(Parse(True));
        GetToken(Token);

        if Token.Type_ = OpRightParen then begin
          break;
        end
        else if Token.Type_ = OpComma then begin
          continue;
        end;

        raise Exception.Create('Expected "," or ")" after function argument.');
      end;
    except
      FreeAndNil(Result);
      raise;
    end;
  end;

  // _______________________________________________________________________________________________

  function TomParser.Parse;
  begin
    Result := ParseAddition; //Unmanaged

    if not Subparsing and (TokenPos < Tokens.Count) then begin
      raise Exception.Create('Invalid expression.');
    end;
  end;

  // _______________________________________________________________________________________________

  constructor TomParser.Create(Tokens: TObjectList<TomToken>);
  begin
    Self.Tokens := Tokens;
    Self.TokenPos := 0;
  end;

  // _______________________________________________________________________________________________

  class function TomFunctionData.RetrieveByName(Identifier: String): TomFunctionData;
  var
  Data: TomFunctionData;
  begin
    for Data in C_FunctionValidators do begin
      if (AnsiCompareText(Data.Name, Identifier) = 0) or Data.IsEmpty then begin
        Result := Data;
        break;
      end;
    end;
  end;

  function TomFunctionData.IsEmpty: Boolean;
  begin
    Result := (Name = 'invalid');
  end;


end.
