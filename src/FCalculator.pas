unit FCalculator;

interface

uses
    omExpressions
  , omParser
  , omLexer
  , omToken
  , Winapi.Windows
  , Winapi.Messages
  , System.SysUtils
  , System.Variants
  , System.Classes
  , System.Generics.Collections
  , System.Actions
  , Vcl.Graphics
  , Vcl.Controls
  , Vcl.Forms
  , Vcl.Dialogs
  , Vcl.StdCtrls
  , Vcl.Buttons
  , Vcl.ExtCtrls
  , Vcl.ActnList;

type
  TCalculator = class(TForm)
    Panel1: TPanel;
    Solution: TEdit;
    EquationHistory: TLabel;
    Button7: TPanel;
    Button8: TPanel;
    Button9: TPanel;
    Button4: TPanel;
    Button5: TPanel;
    Button6: TPanel;
    Button1: TPanel;
    Button2: TPanel;
    Button3: TPanel;
    Button0: TPanel;
    ButtonDecimal: TPanel;
    ButtonCE: TPanel;
    ButtonPlus: TPanel;
    ButtonMinus: TPanel;
    ButtonMultiply: TPanel;
    ButtonDivide: TPanel;
    ButtonEqual: TPanel;
    ButtonRightParen: TPanel;
    ButtonLeftParen: TPanel;

    procedure LightButtonMouseEnter(Sender: TObject);
    procedure LightButtonMouseLeave(Sender: TObject);
    procedure DarkButtonMouseEnter(Sender: TObject);
    procedure DarkButtonMouseLeave(Sender: TObject);
    procedure ButtonEqualMouseEnter(Sender: TObject);
    procedure ButtonEqualMouseLeave(Sender: TObject);

    procedure LightButtonMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure ButtonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure DarkButtonMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure ButtonEqualMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure ButtonEqualMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure ButtonCEMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
    procedure SolutionKeyPress(Sender: TObject; var Key: Char);

  private
    procedure Calculate;
    procedure ChangePanelColor(Panel: TObject; Color: TColor);
    function GetPanelText(Panel: TObject) : String;
  end;

var
  MainForm: TCalculator;

implementation

{$R *.dfm}

  procedure TCalculator.Calculate;
  var
    Lexer: TomLexer;
    Tokens: TObjectList<TomToken>;
    Parser: TomParser;
    Expr: TomExpression;
    EvaluatedExpr: String;
  begin
    Lexer := nil;
    Parser := nil;
    Expr := nil;

    try
      try
      //Tokenize the solution string
        Lexer := TomLexer.Create(MainForm.Solution.Text); //Local
        Tokens := Lexer.Lex;

        //Parse the tokens into an expression
        Parser := TomParser.Create(Tokens); //Local
        Expr := Parser.Parse;

        //Evaluate the expression
        EvaluatedExpr := FloatToStrF(Expr.Evaluate, ffGeneral, 12, 12);
      except
        on ParseException: Exception do begin
          MainForm.EquationHistory.Font.Color := clRed;
          MainForm.EquationHistory.Caption := ParseException.Message;
          Exit;
        end;
      end;
    finally
      if Lexer <> nil then begin
        FreeAndNil(Lexer);
      end;

      if Parser <> nil then begin
        FreeAndNil(Parser);
      end;

      if Expr <> nil then begin
        FreeAndNil(Expr);
      end;
    end;

    MainForm.EquationHistory.Font.Color := clGrayText;
    MainForm.EquationHistory.Caption := MainForm.Solution.Text;
    MainForm.Solution.Text := EvaluatedExpr;
    MainForm.Solution.SelStart := Length(MainForm.Solution.Text);
  end;

  // _______________________________________________________________________________________________
  { Helpers }
  procedure TCalculator.ChangePanelColor(Panel: TObject; Color: TColor);
  begin
    if Panel.ClassType = TPanel then begin
      TPanel(Panel).Color := Color;
    end
  end;

  // _______________________________________________________________________________________________

  function TCalculator.GetPanelText(Panel: TObject) : String;
  begin
    if Panel.ClassType = TPanel then begin
      Result := TPanel(Panel).Caption
    end
    else begin
      Result := '';
    end
  end;

  // _______________________________________________________________________________________________
  { A whole bunch of panel event handling }

  procedure TCalculator.LightButtonMouseEnter(Sender: TObject);
  begin
    ChangePanelColor(Sender, $005F5147);
  end;

  // _______________________________________________________________________________________________

  procedure TCalculator.LightButtonMouseLeave(Sender: TObject);
  begin
    ChangePanelColor(Sender, $00554940);
  end;

  // _______________________________________________________________________________________________

  procedure TCalculator.ButtonEqualMouseEnter(Sender: TObject);
  begin
    ChangePanelColor(Sender, $00FFA54A);
  end;

  // _______________________________________________________________________________________________

  procedure TCalculator.ButtonEqualMouseLeave(Sender: TObject);
  begin
    ChangePanelColor(Sender, clMenuHighlight);
  end;

  // _______________________________________________________________________________________________

  procedure TCalculator.DarkButtonMouseEnter(Sender: TObject);
  begin
    ChangePanelColor(Sender, $00554742);
  end;

  // _______________________________________________________________________________________________

  procedure TCalculator.DarkButtonMouseLeave(Sender: TObject);
  begin
    ChangePanelColor(Sender, $004E413D);
  end;

  // _______________________________________________________________________________________________

  procedure TCalculator.LightButtonMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
    X, Y: Integer);
  begin
    ChangePanelColor(Sender, $00554940);
  end;

// _______________________________________________________________________________________________

  procedure TCalculator.ButtonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
    X, Y: Integer);
  var
    SelStart: Integer;
    KeyString: String;
    NewSolution: String;
  begin
    SelStart := MainForm.Solution.SelStart + 1;
    KeyString := GetPanelText(Sender);
    NewSolution := MainForm.Solution.Text;

    ChangePanelColor(Sender, $0065564B);
    Insert(KeyString, NewSolution, SelStart);

    MainForm.Solution.Text := NewSolution;
    MainForm.Solution.SelStart := SelStart;
    MainForm.Solution.SelLength := 0;
  end;

  // _______________________________________________________________________________________________

  procedure TCalculator.DarkButtonMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
    X, Y: Integer);
  begin
    ChangePanelColor(Sender, $004E413D);
  end;

  // _______________________________________________________________________________________________

  procedure TCalculator.ButtonEqualMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
    Y: Integer);
  begin
    ChangePanelColor(Sender, $00FFB66C);
    Calculate;
  end;

  // _______________________________________________________________________________________________

  procedure TCalculator.ButtonEqualMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
    Y: Integer);
  begin
     ChangePanelColor(Sender, clMenuHighlight);
  end;

  // _______________________________________________________________________________________________

  procedure TCalculator.ButtonCEMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
    X, Y: Integer);
  begin
    ChangePanelColor(Sender, $0065564B);
    MainForm.Solution.Text := '';
    MainForm.Solution.SelStart := 0;
    MainForm.EquationHistory.Caption := '';
  end;

  // _______________________________________________________________________________________________

  procedure TCalculator.SolutionKeyPress(Sender: TObject; var Key: Char);
  begin
    if Key = #13 then begin
      MainForm.Calculate;
    end;
  end;

  // _______________________________________________________________________________________________


end.
