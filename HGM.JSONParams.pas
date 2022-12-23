unit HGM.JSONParams;

interface

uses
  System.Classes, System.JSON, System.Generics.Collections, HGM.ArrayHelpers;

type
  TJSONParam = class
  private
    FJSON: TJSONObject;
    procedure SetJSON(const Value: TJSONObject);
    function GetCount: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Add(const Key: string; const Value: string): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: Integer): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: Extended): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: Boolean): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: TDateTime; Format: string = ''): TJSONParam; overload; virtual;
    function AddPeriod(const Key: string; Value, Value2: TJSONValue): TJSONParam; overload; virtual;
    function AddPeriodAlt(const Key: string; Value, Value2: TJSONValue): TJSONParam; overload; virtual;
    function AddPeriod(const Key: string; const Value, Value2: string): TJSONParam; overload; virtual;
    function AddPeriodAlt(const Key: string; const Value, Value2: string): TJSONParam; overload; virtual;
    function AddPeriod(const Key: string; Value, Value2: integer; VB, VB2: Boolean): TJSONParam; overload; virtual;
    function AddPeriodAlt(const Key: string; Value, Value2: integer; VB, VB2: Boolean): TJSONParam; overload; virtual;
    function AddPeriod(const Key: string; Value, Value2: Extended; VB, VB2: Boolean): TJSONParam; overload; virtual;
    function AddPeriodAlt(const Key: string; Value, Value2: Extended; VB, VB2: Boolean): TJSONParam; overload; virtual;
    function AddPeriodDateTime(const Key: string; const Value, Value2: TDateTime; Format: string = ''): TJSONParam; overload; virtual;
    function AddPeriodDateTimeAlt(const Key: string; const Value, Value2: TDateTime; Format: string = ''): TJSONParam; overload; virtual;
    function AddPeriodDate(const Key: string; const Value, Value2: TDate; Format: string = ''): TJSONParam;
    function AddPeriodDateAlt(const Key: string; const Value, Value2: TDate; Format: string = ''): TJSONParam;
    function Add(const Key: string; const Value: TJSONValue): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: TJSONParam): TJSONParam; overload; virtual;
    function Add(const Key: string; Value: TArray<string>): TJSONParam; overload; virtual;
    function Add(const Key: string; Value: TArray<Integer>): TJSONParam; overload; virtual;
    function Add(const Key: string; Value: array of integer): TJSONParam; overload; virtual;
    function Add(const Key: string; Value: TArray<TJSONValue>): TJSONParam; overload; virtual;
    function Add(const Key: string; Value: TArray<TJSONParam>): TJSONParam; overload; virtual;
    function GetOrCreateObject(const Name: string): TJSONObject;
    function GetOrCreate<T: TJSONValue, constructor>(const Name: string): T;
    procedure Delete(const Key: string); virtual;
    procedure Clear; virtual;
    property Count: Integer read GetCount;
    property JSON: TJSONObject read FJSON write SetJSON;
    function ToJsonString(FreeObject: Boolean = False): string; virtual;
    function ToStream: TStringStream;
  end;

var
  DATE_TIME_FORMAT: string = 'DD.MM.YYYY hh:nn';

implementation

uses
  System.SysUtils, System.DateUtils;

{ Fetch }

type
  Fetch<T> = class
    type
      TFetchProc = reference to procedure(const Element: T);
  public
    class procedure All(const Items: TArray<T>; Proc: TFetchProc);
  end;

{ Fetch<T> }

class procedure Fetch<T>.All(const Items: TArray<T>; Proc: TFetchProc);
var
  Item: T;
begin
  for Item in Items do
    Proc(Item);
end;

{ TJSONParam }

function TJSONParam.Add(const Key, Value: string): TJSONParam;
begin
  Delete(Key);
  FJSON.AddPair(Key, Value);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: TJSONValue): TJSONParam;
begin
  Delete(Key);
  FJSON.AddPair(Key, Value);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: TJSONParam): TJSONParam;
begin
  Add(Key, TJSONValue(Value.JSON.Clone));
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: TDateTime; Format: string): TJSONParam;
begin
  if Format.IsEmpty then
    Format := DATE_TIME_FORMAT;
  Add(Key, FormatDateTime(Format, System.DateUtils.TTimeZone.local.ToUniversalTime(Value)));
  Result := Self;
end;

function TJSONParam.AddPeriodDateTime(const Key: string; const Value, Value2: TDateTime; Format: string): TJSONParam;
var
  V1, V2: string;
begin
  if Format.IsEmpty then
    Format := DATE_TIME_FORMAT;
  if Value <> 0 then
    V1 := FormatDateTime(Format, System.DateUtils.TTimeZone.local.ToUniversalTime(Value))
  else
    V1 := '';
  if Value2 <> 0 then
    V2 := FormatDateTime(Format, System.DateUtils.TTimeZone.local.ToUniversalTime(Value2))
  else
    V2 := '';
  Result := AddPeriod(Key, V1, V2);
end;

function TJSONParam.AddPeriodDate(const Key: string; const Value, Value2: TDate; Format: string): TJSONParam;
var
  V1, V2: string;
begin
  if Format.IsEmpty then
    Format := DATE_TIME_FORMAT;
  if Value <> 0 then
    V1 := FormatDateTime(Format, Value)
  else
    V1 := '';
  if Value2 <> 0 then
    V2 := FormatDateTime(Format, Value2)
  else
    V2 := '';
  Result := AddPeriod(Key, V1, V2);
end;

function TJSONParam.AddPeriodDateAlt(const Key: string; const Value, Value2: TDate; Format: string): TJSONParam;
var
  V1, V2: string;
begin
  if Format.IsEmpty then
    Format := DATE_TIME_FORMAT;
  if Value <> 0 then
    V1 := FormatDateTime(Format, Value)
  else
    V1 := '';
  if Value2 <> 0 then
    V2 := FormatDateTime(Format, Value2)
  else
    V2 := '';
  Result := AddPeriodAlt(Key, V1, V2);
end;

function TJSONParam.AddPeriod(const Key: string; Value, Value2: TJSONValue): TJSONParam;
var
  JO: TJSONObject;
begin
  JO := TJSONObject.Create;
  if Assigned(Value) then
    JO.AddPair('from', Value);
  if Assigned(Value2) then
    JO.AddPair('to', Value2);
  Add(Key, JO);
  Result := Self;
end;

function TJSONParam.AddPeriod(const Key: string; Value, Value2: integer; VB, VB2: Boolean): TJSONParam;
var
  V1, V2: TJSONValue;
begin
  if VB then
    V1 := TJSONNumber.Create(Value)
  else
    V1 := nil;
  if VB2 then
    V2 := TJSONNumber.Create(Value2)
  else
    V2 := nil;
  Result := AddPeriod(Key, V1, V2);
end;

function TJSONParam.AddPeriod(const Key: string; Value, Value2: Extended; VB, VB2: Boolean): TJSONParam;
begin
  Result := AddPeriod(Key, TJSONNumber.Create(Value), TJSONNumber.Create(Value2));
end;

function TJSONParam.AddPeriodDateTimeAlt(const Key: string; const Value, Value2: TDateTime; Format: string): TJSONParam;
var
  V1, V2: string;
begin
  if Format.IsEmpty then
    Format := DATE_TIME_FORMAT;
  if Value <> 0 then
    V1 := FormatDateTime(Format, System.DateUtils.TTimeZone.local.ToUniversalTime(Value))
  else
    V1 := '';
  if Value2 <> 0 then
    V2 := FormatDateTime(Format, System.DateUtils.TTimeZone.local.ToUniversalTime(Value2))
  else
    V2 := '';
  Result := AddPeriodAlt(Key, V1, V2);
end;

function TJSONParam.AddPeriodAlt(const Key: string; Value, Value2: TJSONValue): TJSONParam;
var
  JO: TJSONObject;
begin
  JO := TJSONObject.Create;
  if Assigned(Value) then
    JO.AddPair('after', Value);
  if Assigned(Value2) then
    JO.AddPair('before', Value2);
  Add(Key, JO);
  Result := Self;
end;

function TJSONParam.AddPeriodAlt(const Key: string; Value, Value2: integer; VB, VB2: Boolean): TJSONParam;
var
  V1, V2: TJSONValue;
begin
  if VB then
    V1 := TJSONNumber.Create(Value)
  else
    V1 := nil;
  if VB2 then
    V2 := TJSONNumber.Create(Value2)
  else
    V2 := nil;
  Result := AddPeriodAlt(Key, V1, V2);
end;

function TJSONParam.AddPeriodAlt(const Key: string; Value, Value2: Extended; VB, VB2: Boolean): TJSONParam;
var
  V1, V2: TJSONValue;
begin
  if VB then
    V1 := TJSONNumber.Create(Value)
  else
    V1 := nil;
  if VB2 then
    V2 := TJSONNumber.Create(Value2)
  else
    V2 := nil;
  Result := AddPeriodAlt(Key, V1, V2);
end;

function TJSONParam.AddPeriod(const Key: string; const Value, Value2: string): TJSONParam;
var
  JO: TJSONObject;
begin
  JO := TJSONObject.Create;
  if not Value.IsEmpty then
    JO.AddPair('from', Value);
  if not Value2.IsEmpty then
    JO.AddPair('to', Value2);
  Add(Key, JO);
  Result := Self;
end;

function TJSONParam.AddPeriodAlt(const Key: string; const Value, Value2: string): TJSONParam;
var
  JO: TJSONObject;
begin
  JO := TJSONObject.Create;
  if not Value.IsEmpty then
    JO.AddPair('after', Value);
  if not Value2.IsEmpty then
    JO.AddPair('before', Value2);
  Add(Key, JO);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: Boolean): TJSONParam;
begin
  Add(Key, TJSONBool.Create(Value));
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: Integer): TJSONParam;
begin
  Add(Key, TJSONNumber.Create(Value));
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: Extended): TJSONParam;
begin
  Add(Key, TJSONNumber.Create(Value));
  Result := Self;
end;

function TJSONParam.Add(const Key: string; Value: TArray<TJSONValue>): TJSONParam;
var
  JArr: TJSONArray;
begin
  JArr := TJSONArray.Create;
  Fetch<TJSONValue>.All(Value, JArr.AddElement);
  Add(Key, JArr);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; Value: TArray<TJSONParam>): TJSONParam;
var
  JArr: TJSONArray;
  Item: TJSONParam;
begin
  JArr := TJSONArray.Create;
  for Item in Value do
  begin
    JArr.AddElement(Item.JSON);
    Item.JSON := nil;
  end;

  Add(Key, JArr);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; Value: array of integer): TJSONParam;
var
  Items: TArrayOfInteger;
begin
  Items.Add(Value);
  Result := Add(Key, Items);
end;

function TJSONParam.Add(const Key: string; Value: TArray<Integer>): TJSONParam;
var
  JArr: TJSONArray;
  Item: Integer;
begin
  JArr := TJSONArray.Create;
  for Item in Value do
    JArr.Add(Item);

  Add(Key, JArr);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; Value: TArray<string>): TJSONParam;
var
  JArr: TJSONArray;
  Item: string;
begin
  JArr := TJSONArray.Create;
  for Item in Value do
    JArr.Add(Item);

  Add(Key, JArr);
  Result := Self;
end;

procedure TJSONParam.Clear;
begin
  FJSON.Free;
  FJSON := TJSONObject.Create;
end;

constructor TJSONParam.Create;
begin
  FJSON := TJSONObject.Create;
end;

procedure TJSONParam.Delete(const Key: string);
var
  Item: TJSONPair;
begin
  Item := FJSON.RemovePair(Key);
  if Assigned(Item) then
    Item.Free;
end;

destructor TJSONParam.Destroy;
begin
  if Assigned(FJSON) then
    FJSON.Free;
  inherited;
end;

function TJSONParam.GetCount: Integer;
begin
  Result := FJSON.Count;
end;

function TJSONParam.GetOrCreate<T>(const Name: string): T;
begin
  if not FJSON.TryGetValue<T>(Name, Result) then
  begin
    Result := T.Create;
    FJSON.AddPair(Name, Result);
  end;
end;

function TJSONParam.GetOrCreateObject(const Name: string): TJSONObject;
begin
  Result := GetOrCreate<TJSONObject>(Name);
end;

procedure TJSONParam.SetJSON(const Value: TJSONObject);
begin
  FJSON := Value;
end;

function TJSONParam.ToJsonString(FreeObject: Boolean): string;
begin
  Result := FJSON.ToJSON;
  if FreeObject then
    Free;
end;

function TJSONParam.ToStream: TStringStream;
begin
  Result := TStringStream.Create;
  try
    Result.WriteString(ToJsonString);
    Result.Position := 0;
  except
    Result.Free;
    raise;
  end;
end;

end.

