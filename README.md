# BashGitBranchChecklist
A bash script which allows user to create independent checklists which has separate progress between different git branches. It uses dialog command to create an interactive UI.

## Configuration
1. Create checklistConfig.txt in same directory as checklist.sh
2. Enter git path to your project into checklistConfig.txt

```
gitPath=/Path/to/your/project
```

3. Enter checklist items into checklistConfig.txt by putting # at the start on each item. Order must be top to bottom
```
#First item
#Second item
#Third item
```
