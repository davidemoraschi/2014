Sub ReadXML(adoRS, xmlFilePath)
    Call adoRS.Open(xmlFilePath, "Provider=MSDAOSP; Data Source=MSXML2.DSOControl;")
End Sub