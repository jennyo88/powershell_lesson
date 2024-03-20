#!/usr/bin/env bash

# Function to display the lesson plan summary
display_lesson_plan_summary() {
    if [ -f "lesson_plan.txt" ]; then
        clear
        echo "Lesson Plan Summary:"
        less "lesson_plan.txt"
        echo
    else
        echo "Lesson plan not found."
    fi
}

# Function to display the index of PowerShell commands
display_powershell_index() {
    if [ -f "powershell_index.txt" ]; then
        clear
        echo "PowerShell Commands Index:"
        less "powershell_index.txt"
        echo
    else
        echo "PowerShell index not found."
    fi
}

# Function to display lesson titles for a given week
display_lesson_titles() {
    local week_directory="$1"
    local week_number=$(basename "$week_directory" | cut -d '_' -f 2)
    echo "Week $week_number Lessons:"
    for lesson_file in "$week_directory"/lesson_*.txt; do
        lesson_number=$(basename "$lesson_file" | cut -d '_' -f 2 | cut -d '.' -f 1)
        lesson_title=$(head -n 1 "$lesson_file")
        printf "  %-10s: %s\n" "Lesson $lesson_number" "$lesson_title"
    done
}

# Function to display lesson content
display_lesson() {
    local lesson_file="$1"
    if [ -f "$lesson_file" ]; then
        clear
        echo "Lesson Content:"
        fold -s -w $(tput cols) "$lesson_file" | less -FX  # Wrap lines and use less for interactive viewing
    else
        echo "Lesson not found."
    fi
}

# Function to search for keywords in all lesson files
search_keywords() {
    local keyword="$1"
    local search_results
    search_results=$(grep -rin "$keyword" week_*/lesson_*.txt)
    if [ -n "$search_results" ]; then
        while true; do
            clear
            echo "Search Results for: '$keyword'"
            # Number the search results
            echo "$search_results" | nl -w4 -s': '
            read -p "Enter the number of the file to read, or press Enter to return to the main menu: " file_number
            if [ -z "$file_number" ]; then
                break  # Exit the loop if no file number is provided
            elif [ "$file_number" -ge 1 ] && [ "$file_number" -le "$(echo "$search_results" | wc -l)" ]; then
                selected_line=$(echo "$search_results" | sed -n "${file_number}p")
                selected_file=$(echo "$selected_line" | cut -d ':' -f 1)
                display_lesson "$selected_file"
                read -p "Press Enter to return to the search results..."
            else
                echo "Invalid file number. Please enter a valid number or press Enter to return to the main menu."
                read -p "Press Enter to continue..."
            fi
        done
    else
        echo "No results found for: '$keyword'"
        read -p "Press Enter to return to the main menu..."
    fi
}

# Function to display the menu
display_menu() {
    clear
    echo "==============================================================================="
    echo "                             Interactive Lesson Planner                         "
    echo "==============================================================================="
    echo "1. Display Lesson Plan Summary"
    echo "2. Display PowerShell Commands Index"
    echo "3. Start Lesson Planner"
    echo "4. Search for Keywords in Lessons"
    echo "5. Exit"
    echo "==============================================================================="
}

# Function to display the lessons menu heading
display_lessons_menu_heading() {
    echo "==============================================================================="
    echo "                              Lessons Menu                                     "
    echo "==============================================================================="
}

# Function to handle user input for the menu
handle_menu_input() {
    while true; do
        display_menu
        read -p "Enter your choice: " choice
        case $choice in
            1)
                display_lesson_plan_summary
                read -p "Press Enter to return to menu..."
                ;;
            2)
                display_powershell_index
                read -p "Press Enter to return to menu..."
                ;;
            3)
                main  # Call the main function to start the lesson planner
                ;;
            4)
                read -p "Enter the keyword to search for: " keyword
                search_keywords "$keyword"
                ;;
            5)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid choice. Please enter a number from 1 to 5."
                read -p "Press Enter to return to menu..."
                ;;
        esac
    done
}

# Main function
main() {
    # Array of week directories sorted by name
    week_directories=($(ls -d week_* | sort))

    # Start index for week directories
    current_week_index=0

    while [ $current_week_index -ge 0 ] && [ $current_week_index -lt ${#week_directories[@]} ]; do
        week_directory=${week_directories[$current_week_index]}

        clear
        # Display lessons menu heading
        display_lessons_menu_heading

        # Display lesson titles for the current week
        display_lesson_titles "$week_directory"

        # Prompt user for lesson number or command
        read -p "Enter the lesson number, 'n' for next, 'p' for previous, 'w' to select a week, or press Enter to return to the main menu: " input
        case $input in
            n)
                ((current_week_index++)) ;;
            p)
                ((current_week_index--)) ;;
            w)
                read -p "Enter the week number to jump to: " week_number
                # Find the index of the specified week directory
                new_week_index=-1
                for i in "${!week_directories[@]}"; do
                    dir="${week_directories[$i]}"
                    if [[ $dir == "week_$week_number" ]]; then
                        new_week_index=$i
                        break
                    fi
                done
                if [ $new_week_index -ge 0 ]; then
                    current_week_index=$new_week_index
                else
                    echo "Week not found."
                fi
                ;;
            "")
                break ;;  # Return to main menu
            [0-9]*)
                lesson_file="$week_directory/lesson_$input.txt"
                display_lesson "$lesson_file"
                read -p "Press Enter to continue..."
                ;;
            *)
                echo "Invalid input. Please enter a lesson number, 'n', 'p', 'w', or press Enter to return to the main menu." ;;
        esac
    done
}

# Call the function to handle menu input
handle_menu_input
