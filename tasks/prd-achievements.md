# Product Requirements Document: Achievements System

## Introduction/Overview

Crown & Barrel will introduce an achievements system that recognizes and celebrates user milestones and accomplishments in their watch collecting and wearing journey. Achievements will unlock in real-time as users interact with the app, providing immediate feedback and encouraging continued engagement. Each achievement will be represented by a unique trophy image and will be permanently stored once unlocked.

The achievements system aims to enhance user engagement by gamifying the watch collecting experience and providing visual recognition of collecting habits, wearing patterns, and collection growth.

## Goals

1. Implement a flexible achievement system that can track and unlock 50+ different achievements across multiple categories
2. Provide real-time achievement unlocking that responds immediately to user actions
3. Display achievements on individual watch detail pages (watch-specific achievements) and the stats page (global achievements)
4. Show progression tracking for locked achievements to motivate users toward unlocking them
5. Create a permanent achievement history that persists locally on the device
6. Design the system to support future achievement additions that automatically evaluate against existing user data

## User Stories

1. **As a watch collector**, I want to see achievements unlock as I add watches to my collection, so that I feel recognized for growing my collection.

2. **As a regular wearer**, I want to earn achievements for logging wears consistently, so that I'm motivated to track my wearing habits.

3. **As a curious user**, I want to see how close I am to unlocking achievements, so that I know what milestones to work toward next.

4. **As a watch enthusiast**, I want to see which achievements I've earned for a specific watch on its detail page, so that I can appreciate that watch's unique contribution to my collection.

5. **As a data-conscious collector**, I want to view all my achievements in one place on the stats page, so that I can see my overall collecting accomplishments.

6. **As a long-time user**, I want newly added achievements to automatically unlock if I already meet the criteria, so that I'm retroactively recognized for my past activities.

7. **As a diverse collector**, I want to earn achievements for collecting different brands and watch types, so that my collection diversity is recognized.

8. **As a milestone-oriented person**, I want to earn achievements for my first watch, first wear, and other special moments, so that I can remember important moments in my collecting journey.

## Functional Requirements

### Core Achievement System

1. The system must support defining achievements with the following properties:
   - Unique identifier
   - Name (display title)
   - Description (what the achievement represents)
   - Image filename/reference
   - Achievement type/category
   - Unlock criteria (conditions that trigger the achievement)
   - Progress tracking capability (for multi-step achievements)

2. The system must track achievement state for each user:
   - Locked/Unlocked status
   - Unlock date/time (when unlocked)
   - Current progress toward unlock (e.g., "8/10 wears completed")

3. The system must evaluate achievement criteria in real-time whenever relevant user actions occur:
   - Adding a watch to the collection
   - Logging a wear entry
   - Deleting a watch or wear entry (may affect progress)
   - Other achievement-triggering actions

4. The system must automatically unlock achievements when criteria are met and persist the unlock immediately.

### Achievement Categories & Examples

5. The system must include **Collection Size Milestones** (Priority 1):
   - First Watch ("Welcome to the Club")
   - 5 Watches ("Growing Collection")
   - 10 Watches ("Serious Collector")
   - 25 Watches ("Watch Enthusiast")
   - 50 Watches ("Master Collector")
   - 75 Watches ("Elite Collection")
   - 100 Watches ("Century Club")
   - 150 Watches ("Legendary Collector")
   - 200 Watches ("Ultimate Collector")
   - 250+ Watches ("Crown Jewel")

6. The system must include **Wearing Frequency Milestones** (Priority 2):
   - First Wear ("Breaking It In")
   - 10 Total Wears ("Getting Started")
   - 25 Total Wears ("Regular Wearer")
   - 50 Total Wears ("Committed Wearer")
   - 100 Total Wears ("Dedicated Enthusiast")
   - 250 Total Wears ("Wear Champion")
   - 500 Total Wears ("Wear Master")
   - 1000 Total Wears ("Millennium Wearer")
   - 2500 Total Wears ("Epic Wearer")
   - 5000+ Total Wears ("Legendary Wearer")

7. The system must include **Consistency/Streak Achievements** (Priority 3):
   - 3 Days in a Row ("Getting Into Rhythm")
   - 7 Days in a Row ("Weekly Warrior")
   - 14 Days in a Row ("Two Week Streak")
   - 30 Days in a Row ("Monthly Master")
   - 60 Days in a Row ("Two Month Champion")
   - 90 Days in a Row ("Quarter Year Streak")
   - 180 Days in a Row ("Half Year Hero")
   - 365 Days in a Row ("Year-Long Dedication")
   - **Note**: Streak achievements are maintained as long as the user logs any wear entry on consecutive days. Multiple watches worn on the same day still count as one day toward the streak. For watch-specific streaks (e.g., "Wear a single watch 10 days in a row"), the same watch must be worn on consecutive days, but other watches may also be worn on those same days.

8. The system must include **Diversity Achievements** (Priority 4):
   - 3 Different Brands ("Brand Explorer")
   - 5 Different Brands ("Multi-Brand Collector")
   - 10 Different Brands ("Brand Connoisseur")
   - 15 Different Brands ("Brand Master")
   - Different Watch Types (if tracked: dress, sport, dive, etc.)
   - Different Complications (if tracked: chronograph, GMT, etc.)
   - Different Case Materials (if tracked: steel, gold, titanium, etc.)
   - **Note**: Brand-based achievements will work with existing watch data fields. If brand information is not available for some watches, they will be excluded from brand diversity calculations.

9. The system must include **Special Occasion/First Events** (Priority 5):
   - First Watch Added ("The Journey Begins")
   - First Wear Logged ("First Time Out")
   - First Week of Tracking ("Week One Complete")
   - First Month of Tracking ("Month One Complete")
   - First Year of Tracking ("Anniversary Year")
   - Single Watch Worn 10 Times ("Favorite Watch")
   - Single Watch Worn 50 Times ("True Love")
   - Single Watch Worn 100 Times ("Daily Driver")

10. Each achievement must display progress information when locked:
    - For count-based achievements: "X/Y completed" (e.g., "8/10 watches owned")
    - For streak-based achievements: "Current streak: X days" or "Best streak: X days"

### Display Requirements

11. On individual watch detail pages, the system must display achievements specific to that watch:
    - Achievements earned because of this watch (e.g., "This was your 10th watch" unlocked "Serious Collector")
    - Aggregate achievements earned by wearing this specific watch (e.g., "Worn 50 times" unlocked "True Love")
    - Visual representation of the achievement (trophy image)
    - Achievement name and description
    - Unlock date (if unlocked)

12. On the stats page, the system must display all achievements:
    - Global view of all unlocked achievements
    - Locked achievements with progression indicators (user can toggle visibility of locked achievements)
    - Achievement images
    - Achievement names, descriptions, and unlock dates (if unlocked)
    - Optional: Filter/sort by category, locked/unlocked status

13. Achievement displays must be visually appealing and use consistent styling across all achievements (no rarity hierarchy).

### Data Persistence

14. The system must persist achievement data locally using the existing persistence layer (GRDB).

15. Achievement unlock state and progress must survive app restarts and updates.

16. Achievement data must NOT sync across devices (local only).

17. Once unlocked, achievements must be permanent and cannot be deleted or reset by the user.

18. If user data that contributed to an achievement is deleted (e.g., a watch is removed), the achievement must remain unlocked, but progress toward future related achievements should recalculate accurately.

### Future-Proofing

19. When new achievements are added in future app updates, the system must automatically:
    - Evaluate existing user data against new achievement criteria
    - Unlock any new achievements the user already qualifies for
    - Set the unlock date to the time of evaluation (not backdated)

20. The achievement definition system must be extensible to allow easy addition of new achievement types and criteria.

## Non-Goals (Out of Scope)

1. **Social Features**: Sharing achievements with other users, leaderboards, or comparing achievements between users is out of scope.

2. **Gamification Rewards**: Unlocking achievements will not grant access to app features, premium content, or in-app rewards.

3. **Time-Limited or Seasonal Achievements**: No achievements that expire, are only available during certain periods, or reset periodically.

4. **Cloud Sync**: Achievement data will not sync across devices via iCloud or other cloud services.

5. **Push Notifications**: Initial version will not send push notifications when achievements unlock.

6. **Achievement Deletion/Reset**: Users cannot delete or reset their achievements once unlocked (though users can toggle visibility of locked achievements on the stats page).

7. **User-Created Achievements**: Users cannot define custom achievements.

8. **Photo-Related Achievements**: No achievements will be based on photo uploads or media attachments.

9. **Notes/Journaling Achievements**: No achievements will be based on adding notes or journal entries to watches.

10. **Achievement Tiers**: Achievements do not have multiple tiers (e.g., Bronze/Silver/Gold). Each achievement is unique and stands alone.

11. **Recently Unlocked Section**: The stats page will not include a dedicated "recently unlocked" section.

12. **Target Unlock Rate**: There is no prescribed achievement unlock rate or pacing requirement for new users.

## Design Considerations

1. **Achievement Images**: 50 unique trophy/badge images will be created. Design guidance will be provided separately. All images should follow a consistent visual style with no rarity hierarchy.

2. **UI Components**:
   - Achievement card/badge component for displaying individual achievements
   - Progress indicator component for locked achievements
   - Achievement grid/list layout for stats page
   - Achievement section/widget for watch detail pages

3. **User Feedback**: When an achievement unlocks, the system must provide minimal celebratory feedback including:
   - Light haptic feedback (e.g., success haptic)
   - Subtle animation or visual indicator
   - Brief on-screen notification showing the unlocked achievement
   - The celebration should be noticeable but not disruptive to the user's workflow

4. **Accessibility**: Achievement images must have descriptive alt text, and progression must be readable by screen readers.

## Technical Considerations

1. **Database Schema**: Add tables/models for:
   - Achievement definitions (can be hardcoded or stored in database)
   - User achievement state (unlock status, date, progress)

2. **Achievement Engine**: Implement an evaluation engine that:
   - Listens to relevant data changes (via Combine publishers or observers)
   - Evaluates achievement criteria efficiently
   - Updates achievement state transactionally

3. **Performance**: Achievement evaluation should not noticeably impact app performance. Consider:
   - Evaluating only relevant achievements for each action type
   - Caching achievement state
   - Batch processing when appropriate

4. **Migration**: When introducing achievements to existing users:
   - All 50 achievements should be evaluated on first launch after update
   - Users should receive all achievements they qualify for
   - This process should be performant even for users with large collections

5. **Integration Points**:
   - Watch repository (for collection-based achievements)
   - Wear entry repository (for wearing-based achievements)
   - Stats calculator (may share logic with achievements)

6. **Asset Management**: 50 achievement images should be included in the app bundle as image assets.

## Success Metrics

1. **User Engagement**: Increase in daily active users after achievement launch (target: +10%)

2. **Feature Discovery**: Percentage of users who view the achievements section on stats page (target: 60% within first week)

3. **Data Entry**: Increase in wear entries logged per user (target: +15%)

4. **Collection Growth**: Increase in watches added per user (if applicable)

5. **Retention**: Improved user retention metrics, particularly around milestone achievements (e.g., first week, first month)

6. **Technical Performance**: Achievement evaluation completes in <100ms for 95% of actions

## 50 Achievement Definitions

### Collection Size (10 achievements)
1. **The Journey Begins** - Add your first watch
2. **Growing Collection** - Own 5 watches
3. **Serious Collector** - Own 10 watches
4. **Watch Enthusiast** - Own 25 watches
5. **Master Collector** - Own 50 watches
6. **Elite Collection** - Own 75 watches
7. **Century Club** - Own 100 watches
8. **Distinguished Collector** - Own 150 watches
9. **Ultimate Collector** - Own 200 watches
10. **Crown Jewel** - Own 250 watches

### Wearing Frequency (10 achievements)
11. **Breaking It In** - Log your first wear
12. **Getting Started** - Log 10 total wears
13. **Regular Wearer** - Log 25 total wears
14. **Committed Wearer** - Log 50 total wears
15. **Dedicated Enthusiast** - Log 100 total wears
16. **Wear Champion** - Log 250 total wears
17. **Wear Master** - Log 500 total wears
18. **Millennium Wearer** - Log 1000 total wears
19. **Epic Wearer** - Log 2500 total wears
20. **Legendary Wearer** - Log 5000 total wears

### Consistency/Streaks (10 achievements)
21. **Getting Into Rhythm** - Log wears 3 days in a row
22. **Weekly Warrior** - Log wears 7 days in a row
23. **Two Week Streak** - Log wears 14 days in a row
24. **Monthly Master** - Log wears 30 days in a row
25. **Two Month Champion** - Log wears 60 days in a row
26. **Quarter Year Streak** - Log wears 90 days in a row
27. **Half Year Hero** - Log wears 180 days in a row
28. **Year-Long Dedication** - Log wears 365 days in a row
29. **Weekend Warrior** - Log wears on 10 consecutive weekends
30. **Weekday Champion** - Log wears on 20 consecutive weekdays

### Diversity (10 achievements)
31. **Brand Explorer** - Own watches from 3 different brands
32. **Multi-Brand Collector** - Own watches from 5 different brands
33. **Brand Connoisseur** - Own watches from 10 different brands
34. **Brand Master** - Own watches from 15 different brands
35. **Brand Legend** - Own watches from 20 different brands
36. **Variety Seeker** - Wear 5 different watches in a week
37. **Rotation Master** - Wear 10 different watches in a month
38. **Equal Opportunity** - Wear each watch in collection at least once
39. **Balanced Collector** - No single watch accounts for >30% of wears
40. **True Rotation** - Wear 20 different watches in a quarter

### Special Occasions/Firsts (10 achievements)
41. **First Time Out** - Log your first wear entry
42. **Week One Complete** - Track wears for 7 consecutive days
43. **Month One Complete** - Track wears for 30 consecutive days
44. **Anniversary Year** - Use the app for 1 full year
45. **Favorite Watch** - Wear a single watch 10 times
46. **True Love** - Wear a single watch 50 times
47. **Daily Driver** - Wear a single watch 100 times
48. **Inseparable** - Wear a single watch 250 times
49. **Quick Start** - Log 5 wear entries in your first day
50. **Dedicated Tracker** - Log wear entries on 100 different days

## Implementation Notes

### Streak Calculation Logic

For general streak achievements (e.g., "Log wears 7 days in a row"), the streak is maintained as long as the user logs at least one wear entry on consecutive calendar days. If a user wears multiple watches on the same day, it still counts as a single day toward the streak.

**Example**: User logs watches A, B, and C on Monday, watch A on Tuesday, and watches D and E on Wednesday. This counts as a 3-day streak.

For watch-specific streak achievements (e.g., "Wear the same watch 10 days in a row"), the same specific watch must be worn on consecutive days. However, other watches may also be worn on those same days without breaking the streak.

**Example**: User wears watch A on Monday (also wears watch B), watch A on Tuesday (also wears watch C), and watch A on Wednesday (only). This counts as a 3-day streak for watch A.

### Toggle Functionality

The stats page must include a toggle control that allows users to show or hide locked achievements. The toggle state should be persisted across app sessions. When locked achievements are hidden, only unlocked achievements are displayed.

### Haptic Feedback

When an achievement unlocks, the app should trigger a light success haptic (UINotificationFeedbackGenerator with .success type on iOS). This should be accompanied by a subtle animation and brief on-screen notification, but should not interrupt the user's current task or require dismissal.
