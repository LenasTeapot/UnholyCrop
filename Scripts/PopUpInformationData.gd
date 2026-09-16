extends Resource
class_name PopUpInformationData

@export var type : INFO_TYPE
@export var label : String

enum INFO_TYPE {
    END_QUEST,
    CURRENT_QUEST_REQUIREMENTS,
    CURRENT_QUEST_REWARDS
}