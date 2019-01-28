unit omExpressions;

interface
  uses
      System.Math
    , System.Generics.Collections;

  type
    OpType = (
      Plus,
      Minus,
      Multiply,
      Divide,
      Negate,
      Modulo,
      Exponent
    );

  // _______________________________________________________________________________________________
  // Abstract base class for expressions
  type
    TomExpression = class

  published
    function Evaluate: Double; virtual; abstract;

  end;

  // _______________________________________________________________________________________________
  // Binary expressions evaluate a result from an operator and 2 operands.

  type
    TomExpressionBinary = class(TomExpression)

  private
    Left: TomExpression;
    ExprOp: OpType;
    Right: TomExpression;

  published
    function Evaluate: Double; override;
    constructor Create(Left: TomExpression; ExprOp: OpType; Right: TomExpression);
    destructor Destroy; override;

  end;

  // _______________________________________________________________________________________________
  // Unary expressions evaluate a result from an operator and 1 operand.
  type
    TomExpressionUnary = class(TomExpression)

  private
    ExprOp: OpType;
    Expr: TomExpression;

  published
    function Evaluate: Double; override;
    constructor Create(ExprOp: OpType; Expr: TomExpression);
    destructor Destroy; override;

  end;

  // _______________________________________________________________________________________________
  // Literal expressions are just a wrapper around a single numeric literal.
  type
    TomExpressionLiteral = class(TomExpression)

  private
    Value: Double;

  published
    function Evaluate: Double; override;
    constructor Create(Value: Double);

  end;

  // _______________________________________________________________________________________________
  // Function expressions have a list of arguments which they derive a value from

  type
    TomExpressionFunction = class(TomExpression)

  private
    Name: string;
    ArgumentList: TObjectList<TomExpression>;

  published
    function Evaluate: Double; override;
    constructor Create(Name: String; ArgumentList: TObjectList<TomExpression>);
    destructor Destroy; override;

  end;

implementation

  uses
    System.SysUtils;

  // _______________________________________________________________________________________________
  // Binary Expressions
  function TomExpressionBinary.Evaluate;
  var
    LOperand: Double;
    ROperand: Double;
  begin
    LOperand := Left.Evaluate;
    ROperand := Right.Evaluate;

    if (ExprOp = Divide) and (ROperand = 0) then begin
      raise Exception.Create('Cant divide by zero');
    end;

    case ExprOp of
      Plus:     Result := LOperand + ROperand;
      Minus:    Result := LOperand - ROperand;
      Multiply: Result := LOperand * ROperand;
      Divide:   Result := LOperand / ROperand;
      Exponent: Result := Power(LOperand, ROperand);
      Modulo:   Result := LOperand - Trunc(LOperand/ROperand)*Roperand;
      else begin
        Result := 0;
      end;
    end;
  end;

  // _______________________________________________________________________________________________

  constructor TomExpressionBinary.Create(Left: TomExpression; ExprOp: OpType; Right: TomExpression);
  begin
    Self.Left := Left;
    Self.ExprOp := ExprOp;
    Self.Right := Right;
  end;

  // _______________________________________________________________________________________________

  destructor TomExpressionBinary.Destroy;
  begin
    FreeAndNil(Left);
    FreeAndNil(Right);
  end;

  // _______________________________________________________________________________________________
  // Unary Expressions
  function TomExpressionUnary.Evaluate;
  begin
    Result := Expr.Evaluate;

    case ExprOp of
      Negate: Result := -Result;
    end;
  end;

  // _______________________________________________________________________________________________

  constructor TomExpressionUnary.Create(ExprOp: OpType; Expr: TomExpression);
  begin
    Self.ExprOp := ExprOp;
    Self.Expr := Expr;
  end;

  // _______________________________________________________________________________________________

  destructor TomExpressionUnary.Destroy;
  begin
    FreeAndNil(Expr);
  end;

  // _______________________________________________________________________________________________
  // Literal Expressions
  function TomExpressionLiteral.Evaluate;
  begin
    Result := Value;
  end;

  // _______________________________________________________________________________________________

  constructor TomExpressionLiteral.Create(Value: Double);
  begin
    Self.Value := Value;
  end;

  // _______________________________________________________________________________________________
  // Utility function for use with TomExpressionFunction."rand"

  function RandomFloatRange(const RangeL: Double; const RangeR: Double): Double;
  {$IFDEF INLINE}
  inline;
  {$ENDIF}
  var
    Average, Difference: Double;
  begin
    Average := (RangeL + RangeR) * 0.5;
    Difference := Abs(RangeR - RangeL);
    Result := Average + Difference * (random - 0.5);
  end;

  // _______________________________________________________________________________________________
  // Function Expressions
  function TomExpressionFunction.Evaluate;
  begin
    Result := 0;

    if AnsiCompareText('min', Name) = 0 then begin
      Result := Min(ArgumentList[0].Evaluate, ArgumentList[1].Evaluate);
    end
    else if AnsiCompareText('max', Name) = 0 then begin
      Result := Max(ArgumentList[0].Evaluate, ArgumentList[1].Evaluate);
    end
    else if AnsiCompareText('rand', Name) = 0 then begin
      Result := RandomFloatRange(ArgumentList[0].Evaluate, ArgumentList[1].Evaluate);
    end
    else if AnsiCompareText('abs', Name) = 0 then begin
      Result := Abs(ArgumentList[0].Evaluate);
    end
    else if AnsiCompareText('sqrt', Name) = 0 then begin
      try
        Result := Sqrt(ArgumentList[0].Evaluate);
      except
        raise Exception.Create('Can''t calculate square root of a negative number.');
      end;
    end
    else if AnsiCompareText('round', Name) = 0 then begin
      Result := Round(ArgumentList[0].Evaluate);
    end
    else if AnsiCompareText('remainder', Name) = 0 then begin
      Result := Frac(ArgumentList[0].Evaluate);
    end
  end;

  // _______________________________________________________________________________________________

  constructor TomExpressionFunction.Create(Name: String; ArgumentList: TObjectList<TomExpression>);
  begin
    Self.Name := Name;
    Self.ArgumentList := ArgumentList;
  end;

  // _______________________________________________________________________________________________

  destructor TomExpressionFunction.Destroy;
  begin
    FreeAndNil(ArgumentList);
  end;
end.
