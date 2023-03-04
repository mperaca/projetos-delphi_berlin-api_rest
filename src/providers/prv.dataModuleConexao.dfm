object ProviderDataModuleConexao: TProviderDataModuleConexao
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 271
  Width = 288
  object FDConnectionApi: TFDConnection
    Params.Strings = (
      'Server='
      'User_Name=postgres'
      'Password=postgres'
      'Port='
      'DriverID=PG')
    LoginPrompt = False
    Left = 152
    Top = 32
  end
  object FDPhysPgDriverLink1: TFDPhysPgDriverLink
    Left = 152
    Top = 96
  end
end
