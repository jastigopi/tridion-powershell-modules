<#
**************************************************
* Private utility methods
**************************************************
#>

Function _AddProperty($Object, $Name, $Value)
{
	Add-Member -InputObject $Object -MemberType NoteProperty -Name $Name -Value $Value;
}

Function _HasProperty($Object, $Name)
{
	return Get-Member -InputObject $Object -Name $Name -MemberType NoteProperty;
}

Function _NewObjectWithProperties([Hashtable]$properties)
{
	$result = New-Object -TypeName System.Object;
	foreach($key in $properties.Keys)
	{
		_AddProperty -Object $result -Name $key -Value $properties[$key];
	}
	return $result;
}

function _IsNullUri($Id) 
{
	return (!$Id -or $Id.Trim().ToLowerInvariant() -eq 'tcm:0-0-0')
}

function _GetIdFromInput($Value)
{
	return _GetPropertyFromInput $Value 'Id';
}

function _GetPropertyFromInput($Value, $PropertyName)
{
	if ($Value -is [object])
	{
		if (Get-Member -InputObject $Value -Name $PropertyName)
		{
			return $Value.$PropertyName;
		}
	}
	
	return $Value;
}

function _GetMultipleIdsFromInput($Value)
{
	$result = @();
	foreach($val in @($Value))
	{
		$result += _GetIdFromInput $val;
	}
	return $result;
}

function _GetItemType($Id)
{
	if ($Id)
	{
		$parts = $Id.Split('-');
		switch($parts.Count)
		{
			2 { return 16; }
			3 { return [int]$parts[2] }
			4 { return [int]$parts[2] }
		}
	}
	
	return $null;
}

function _AssertItemType($Id, $ExpectedItemType)
{
	$itemType = _GetItemType $Id;
	if ($itemType -ne $ExpectedItemType)
	{
		throw "Unexpected item type '$itemType'. Expected '$ExpectedItemType'.";
	}
}

function _AssertItemTypeValid($ItemType)
{
	if ($ItemType -le 0 -or ![Enum]::IsDefined([Tridion.ContentManager.CoreService.Client.ItemType], $ItemType))
	{
		throw "Invalid item type: $ItemType";
	}
}

function _GetSystemWideList($Client, $Filter)
{
	return $Client.GetSystemWideList($Filter);
}

function _IsExistingItem($Client, $Id)
{
    Process
    {
        return $Client.IsExistingObject($Id);
    }
}

function _GetItem($Client, $Id)
{
	$readOptions = New-Object Tridion.ContentManager.CoreService.Client.ReadOptions;
	return $Client.Read($Id, $readOptions);
}

function _GetDefaultData($Client, $ItemType, $Parent, $Name = $null)
{
	if ($Client.GetDefaultData.OverloadDefinitions[0].IndexOf('ReadOptions readOptions') -gt 0)
	{
		$readOptions = New-Object Tridion.ContentManager.CoreService.Client.ReadOptions;
		$result = $Client.GetDefaultData($ItemType, $Parent, $readOptions);
	}
	else
	{
		$result = $Client.GetDefaultData($ItemType, $Parent);
	}
	
	if ($Name -and $result)
	{
		$result.Title = $Name;
	}
	return $result;
}

function _SaveItem($Client, $Item)
{
	$readOptions = New-Object Tridion.ContentManager.CoreService.Client.ReadOptions;
	return $Client.Save($Item, $readOptions);
}

function _DeleteItem($Client, $Id)
{
	$Client.Delete($Id);
}

function _ExpandPropertiesIfRequested($List, $ExpandProperties)
{
	if ($ExpandProperties)
	{
		return $List | Get-TridionItem;
	}
	return $List;
}